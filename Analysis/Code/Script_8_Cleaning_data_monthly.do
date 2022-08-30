global wd "Thierry_MAC/Analysis/Output"
cd "$wd"

*************************************************
* Importing the climatic variables in stata
*************************************************

cd "../Temporary/Zonal_stat_monthly"
local disk: pwd
global wd_climate "`disk'"

****Importing the dbase files from dbf
	local type = "Level"
	local allfiles : dir . files "*.dbf"
	display `allfiles'
	foreach file in `allfiles' {
		import dbase using "`file'", clear
		**to save as a stata file create a local with the .dbf extension removed
		local noextension=subinstr("`file'",".dbf","",.)
		local time_id=subinstr("`noextension'","table_","",.)
		keep GID_1 MEAN STD
		rename STD Standard_deviation
		gen time_identifer = " "
		replace time_id = "`time_id'"
		gen year= substr(time_id,1,4)
		gen month = substr(time_id,6,8) 
		
		save "`noextension'", replace
	}
	* Appending the precipiation files into one*
	clear
	local theFiles: dir . files "*.dta"
	di `theFiles'
	append using `theFiles'
	* Renaming the mean and std 
	foreach var in MEAN Standard_deviation  {
		rename `var' `var'_`type'
	}
	save precipiation_file_`type', replace
	* Deleting intermediary files*
	forvalues i=1989(1)2021 {
		foreach m in 01 02 03 04 05 06 07 08 09 10 11 12 {
			erase table_`i'_`m'.dta
		}
	}

****Labeling variables
	label var MEAN_Level "Average precipitation"
	label var Standard_deviation_Level "Standard deviation precipitation"

****Formating the variables as panel data
	gen iso=substr(GID_1,1,3)
	encode GID_1, gen(GID_1_encoded)
	drop if missing(GID_1)
	destring year, replace
	destring month, replace
	egen time_id = group(year month)
	xtset GID_1_encoded time_id

****Saving the dataset
	save "$wd/Precipitation_panel_data_monthly.dta", replace

**************************************
* Merging all data in a single file 
**************************************

****Setting the directory
	cd "$wd"

****Using the panel data of rainfall as the reference
	use Precipitation_panel_data_monthly, clear

****Merging with the data on conflicts (for each month of the year, we merge the regrion with all conflicts that occured)
	merge 1:m GID_1 year month using Armed_conflicts_UCDP

****Dropping unusable variables 
	* Observations with no area id
	drop if missing(GID_1)
	* Observations with no climate data because their area is too small for the resolution of climatic maps
	drop if _merge == 2

****Generating a variable that shows the incidence of conflict
	gen conflict_incidence = 1 if _merge== 3 & type_of_violence==2
	replace conflict_incidence = 0 if _merge== 1 | type_of_violence!=2
	
	gen conflict_incidence_any = 1 if _merge== 3
	replace conflict_incidence_any = 0 if _merge== 1
	
	drop _merge
	
****Filling the values of observations with no region value
	kountry iso, from(iso3c) geo(un)
	
****Colapsing the dataset at the year level
	collapse (mean) active_year MEAN_Level ///
	(sum) conflict_incidence conflict_incidence_any total_deaths ///
	(firstnm) time_identifer iso GID_1 NAMES_STD GEO ///
	,by(GID_1_encoded year month)

	
****Relabelling variables
	label var conflict_incidence "1-Conflict Incidence 0-No  incidence"
	label var conflict_incidence_any "1-Conflict incidence 0-No incidence"	
	
****Creating climatic anomalies based on long run average
	* Creating the climatic mean per GID_1 for all year
	bysort GID_1: egen mean_year_Level = mean(MEAN_Level)
	* Creating the climatic standard deviation per GID_1 for all year
	bysort GID_1: egen sd_year_Level = sd(MEAN_Level)
	* Creating the standardized climatic variable per year
	gen z_Level = (MEAN_Level - mean_year_Level) / sd_year_Level
	* Droping intermediate variables
	drop mean_year_Level sd_year_Level
	* Labeling variables
	label var z_Level "standardised values of Level per GID_1"
	
****Merging the HDI data with the conflicts data	
	merge m:1 GID_1 year using HDI_data
	drop if _merge==2
	drop _merge

****Generating logarithmic socio economic variables
	foreach var in gnic pop lifexp{
		gen ln_`var' = ln(`var')
		label var ln_`var' "Logarithm of `var'"
	}

****Encoding countries for cluster analyses
	encode iso, gen (iso_encoded)

****Generating a number of non-state conflicts
	gen number_of_conflict = conflict_incidence
	
****Generating a conflict incidence and onset variable	
	foreach var in conflict_incidence conflict_incidence_any {
		replace `var' = 1 if `var' > 0
		if "`var'" =="conflict_incidence_any" {
			local suffix = "_any"
		}
		else {
			local suffix = ""
		}
		* Creating a variable with the number without conflict
			gen peace_years`suffix' =.
			replace peace_years`suffix' = 0 if year == 1989
			replace peace_years`suffix' = 0 if `var' == 0
			replace peace_years`suffix' = 1 if year == 1989 & `var' == 1

		* Creating a variable with the number of years in peace
			forvalues i=1990(1)2019{
				by GID_1_encoded (year), sort: replace peace_years`suffix' = 0 if `var' == 1 & year==`i'
				by GID_1_encoded (year), sort: replace peace_years`suffix' = peace_years`suffix'[_n-1] + 1/12 if `var' == 0 & year==`i'
			}

		* Creating the conflict onset variable
			gen onset`suffix'_2 = 0
			by GID_1_encoded (year), sort: replace onset`suffix'_2 = 1 if `var'==1 & peace_years`suffix'[_n-1] >= 2
			
		* Creating the conflict onset variable
			gen onset`suffix'_5 = 0
			by GID_1_encoded (year), sort: replace onset`suffix'_5 = 1 if `var'==1 & peace_years`suffix'[_n-1] >= 5 
	}
	
****Dropping regions with unbalanced observations across the years 
	by GID_1_encoded (time_id), sort: gen obs_count = _N
	tab GID_1 if obs_count < 396
	drop if obs_count < 396

****Saving the intermediary file
	save regression_file_monthly, replace
	
****Merging ACLED dataset - Download the ACLED data and input in the Output foder to run this part of the code

	* Importing the ACLED coordinates data from excel format
	import excel "GID_1_joined_ACLED.xlsx", clear firstrow

	* Merge the ACLED coordinates with ACLED detailed data on conflicts
	merge 1:1 data_id using Armed_conflicts_ACLED
	
	* Dropping conflicts incidence with no coordinates
	drop if _merge==2

	* Dropping variable of no interest
	drop admin* notes source_scale timestamp _merge longitude geo_precision latitude location region interaction inter2 assoc_actor_2 actor2 inter1 assoc_actor_1 actor1 time_precision event_date iso
	
	* Displaying the number of event types
	table sub_event_type, c(mean fatalities)
	table event_type, c(mean fatalities)
	tab sub_event_type event_type
	
	* Keeping armed conflicts
	keep if sub_event_type =="Armed clash" & fatalities > 0
	
	* Collapsing the data at the month level
	collapse (mean) fatalities data_id, by(GID_1 year month)

	* Saving the ACLED data
	save ACLED_dta_GID_month, replace
	
	* Merging the ACLED data with the main panel data
	use regression_file_monthly.dta, clear
	merge 1:1 GID_1 year month using ACLED_dta_GID_month.dta
	* Dropping ACLED obervation with no rainfall record
	drop if _merge ==2

	* Creating the conflict incidence and onset data with ACLED records
	replace data_id = 0 if missing(data_id) & year >1996
	replace data_id = 1 if data_id > 0 & !missing(data_id)
	rename data_id conflict_inc_ACLED
	gen peace_years_ACLED =.
	replace peace_years_ACLED = 0 if year == 1997
	replace peace_years_ACLED = 0 if conflict_inc_ACLED == 0
	replace peace_years_ACLED = 1 if year == 1997 & conflict_inc_ACLED == 0
	forvalues i=1998(1)2019{
		by GID_1_encoded (year), sort: replace peace_years_ACLED = 0 if conflict_inc_ACLED == 1 & year==`i'
		by GID_1_encoded (year), sort: replace peace_years_ACLED = peace_years_ACLED[_n-1] + 1/12 if peace_years_ACLED == 0 & year==`i'
	}	
	gen onset_ACLED = 0
	by GID_1_encoded (year), sort: replace onset_ACLED = 1 if conflict_inc_ACLED==1 & peace_years[_n-1] >= 2 

	drop _merge peace_years_ACLED
*/

****Merging data with GNI at the country levels
	merge m:1 iso year using GNI_per_capita_country
	drop if _merge==2
	drop _merge
	gen ln_GNI_per_capita = ln(GNI_per_capita)
	
****Formating the dataset as panel data
	egen time_id = group(year month)
	xtset GID_1_encoded time_id
	
*************************
*Cleaning the final data
*************************
****Labelling all variables to meaningful names for regression output
	label var GID_1_encoded "Unique code of the subnational region/province"
	label var GID_1 "Unique code of the subnational region/province"
	label var year "Year"
	label var onset_2 "Onset of a new conflict in 2 years"
	label var onset_2 "Onset of a new conflict in 5 years"
	label var conflict_incidence "Conflict incidence"
	label var total_deaths "Number of deaths"
	label var GEO "Continental region"
	label var iso "Country's iso3c code"
	label var iso_encoded "Country's iso3c code"
	rename NAMES_STD Country
	label var Country "Country"
	label var peace_years "Number of years wihtout any conflict"
	label var MEAN_Level "Mean precipiation"
	label var ln_gnic "Log(income per capita)"
	label var ln_pop "Log(population)"
	label var ln_lifexp "Log(life expectancy)"
	label var ln_GNI_per_capita "Log(national income per capita)"


***Displaying the number of conflict by GEO
	levelsof GEO, local(levels)
	foreach l of local levels {
	display "`l' Conflict incidences"
	qui sum conflict_incidence if GEO =="`l'"
	di r(mean)*r(N)
	display "`l' Conflict onsets"
	qui sum onset_2 if GEO =="`l'"
	di r(mean)*r(N)
	}

****Dropping Europe and Ocenia because there are too few number of conflicts
	drop if GEO =="Europe" | GEO=="Oceania"
	* create a dummy variable for every country
	tab GEO, gen(Continent_)

****Save intermediary dataset
	save regression_file_monthly, replace
	
****Joining the data to the world shapefile to perform spatial econometrics regressions
	shp2dta using "..\Temporary\GADM_GID_1.shp", database("Coordinates_data.dta") coordinates("Coordinates_lat_long.dta") replace
	
	use Coordinates_data, clear
	merge 1:m GID_1 using "regression_file_monthly.dta"
	drop if _merge==1
	spset _ID
	spset, modify shpfile(Coordinates_lat_long)
	spset, modify coordsys(latlong, kilometers)
	
****Creating a variable describing the occurence of conflict in regions during the period of study
	bysort GID_1: egen conflict_variation= mean(conflict_incidence)
	bysort GID_1: egen onset_2_variation= mean(onset_2)
	
**** generatinng the number of peace years in the previous observations
	by _ID (time_id), sort: gen L_peace_year = peace_years[_n - 1]
	
****Generating non-conflict splines 
	mkspline non_conflict_y_5 5 non_conflict_y_10 10 non_conflict_y_15 15 non_conflict_y_20 20 non_conflict_y_25 25 non_conflict_y_more_25 = peace_years, marginal
	
****Saving the dataset
	save regression_file_monthly, replace
