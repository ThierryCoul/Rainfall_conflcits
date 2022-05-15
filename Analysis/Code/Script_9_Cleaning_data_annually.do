*global wd "Thierry_MAC/Analysis/Output"
*cd "$wd"

*************************************************
* Importing the climatic variables in stata
*************************************************
cd "../Temporary/Zonal_stat_annual"
local disk: pwd
global wd_climate "`disk'"

****Importing the dbase files from dbf
	local type = "Level"
	local allfiles : dir . files "*.dbf"
	display `allfiles'
	foreach file in `allfiles' {
		import dbase using "`file'", clear
		*to save as a stata file create a local variable with the .dbf extension removed
		local noextension=subinstr("`file'",".dbf","",.)
		local time_id=subinstr("`noextension'","table_","",.)
		keep GID_1 MEAN STD
		rename STD Standard_deviation
		gen year =.
		replace year = `time_id'
		save "`noextension'", replace
	}

	* Appending the precipiation files into one
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
	forvalues i=1989(1)2019 {
	erase table_`i'.dta
	}

****Labeling variables
	label var MEAN_Level "Average precipitation"
	label var Standard_deviation_Level "Standard deviation precipitation"

****Formating the variables as panel data
	*Extracting information of countries
	gen iso=substr(GID_1,1,3)
	encode GID_1, gen(GID_1_encoded)
	*Dropping observations with missing ids
	drop if missing(GID_1)
	*Set dataset as a panel data
	xtset GID_1_encoded year

****Saving the dataset
	save "$wd/Precipitation_panel_data", replace

**************************************
* Merging all data in a single file 
**************************************

****Setting the directory
	cd "$wd"
	cd "../Output"

****Using the panel data of rainfall as the reference
	use Precipitation_panel_data, clear

****Merging with the data on conflicts (for each month of the year, we merge the regrion with all conflicts that occured)
	merge 1:m GID_1 year using Armed_conflicts_UCDP

****Dropping unusable variables 
	* Observations with no area id
	drop if missing(GID_1)
	* Observations with no climate data because their area is too small for the resolution of climatic maps
	drop if _merge == 2

****Generating a variable that shows the incidence of conflict
	gen conflict_incidence = 1 if _merge== 3 & type_of_violence==2
	replace conflict_incidence = 0 if _merge== 1 | type_of_violence!=2
	label var conflict_incidence "1-Conflict Incidence 0-No  incidence"
	gen conflict_incidence_any = 1 if _merge== 3
	replace conflict_incidence_any = 0 if _merge== 1
	label var conflict_incidence_any "1-Conflict incidence 0-No incidence"

	drop _merge

****Filling the values of observations with no region value
	kountry iso, from(iso3c) geo(un)
	
****Colapsing the dataset at the year level
	collapse (mean) active_year MEAN_Level ///
	(sum) conflict_incidence conflict_incidence_any total_deaths ///
	(firstnm) region iso GID_1 NAMES_STD GEO ///
	,by(GID_1_encoded year)


****Encoding countries for cluster analyses
	encode iso, gen (iso_encoded)

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
	
****Merge the HDI data with the conflicts data	
	merge 1:1 GID_1 year using HDI_data
	drop if _merge==2
	drop _merge

****Merge data with GNI at the country levels
	merge m:1 iso year using GNI_per_capita_country
	drop if _merge==2
	drop _merge
	gen ln_GNI_per_capita = ln(GNI_per_capita)
		
****Generating logarithmic socioeconomic variables
	foreach var in gnic pop lifexp{
		gen ln_`var' = ln(`var')
		label var ln_`var' "Logarithm of `var'"
	}

****Number of non-state conflicts
	gen number_of_conflict = conflict_incidence

****Conflict incidence	
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
			by GID_1_encoded (year), sort: replace peace_years`suffix' = peace_years`suffix'[_n-1] + 1 if `var' == 0 & year==`i'
		}

		* Creating the conflict onset variable
			gen onset`suffix' = 0
			by GID_1_encoded (year), sort: replace onset`suffix' = 1 if `var'==1 & peace_years`suffix'[_n-1] >= 2 

	}
	
****Saving the intermediary file
	save regression_file_CHIRPS_precipitation, replace
	
****Merging ACLED dataset
/* Download the ACLED data and input in the Output foder to run this part of the code 
	* Importing the ACLED data id and GID_1 from csv to stata
	import excel "ACLED_Armed_conflicts.xlsx", clear firstrow
	
	* Merging the ACLED id with the ACLED statistics
	merge 1:1 data_id using Armed_conflicts_ACLED
	drop if _merge==2
	
	* Dropping unusuable variables
	drop admin* notes source_scale timestamp _merge longitude geo_precision latitude location region interaction inter2 assoc_actor_2 actor2 inter1 assoc_actor_1 actor1 time_precision event_date iso
	
	* Checking the statistics of the ACLED data
	table sub_event_type, c(mean fatalities)
	table event_type, c(mean fatalities)
	tab sub_event_type event_type
	
	* Collapsing the data at the regional year level
	collapse fatalities data_id, by(GID_1 year)
	
	* Saving the intermediary file
	save ACLED_dta_GID_year, replace
	
	* Using the main panel data
	use regression_file_CHIRPS_precipitation.dta, clear
	
	* Merging the main panel data with the intermediary file
	merge 1:1 GID_1 year using ACLED_dta_GID_year.dta
	drop if _merge ==2
	
	* Recode the variable of interest
		* Replacing the ACLED conflict incidence to 0 for regions with no conflict incidence
		replace data_id = 0 if missing(data_id) & year >1996
		* Replacing the ACLED conflict incidence to 1 for regions with a conflict incidence		
		replace data_id = 1 if data_id > 0 & !missing(data_id)
	
	* Rename the variable of interest with a more meaningful name
	rename data_id conflict_inc_ACLED	
	
	* Create the onset variable with the procedure used for UCDP GED above
		* Generating a variable containing the number of year in peace
		gen peace_years_ACLED =.
		replace peace_years_ACLED = 0 if year == 1997
		replace peace_years_ACLED = 0 if conflict_inc_ACLED == 0
		replace peace_years_ACLED = 1 if year == 1997 & conflict_inc_ACLED == 0
		forvalues i=1998(1)2019{
			by GID_1_encoded (year), sort: replace peace_years_ACLED = 0 if conflict_inc_ACLED == 1 & year==`i'
			by GID_1_encoded (year), sort: replace peace_years_ACLED = peace_years_ACLED[_n-1] + 1 if peace_years_ACLED == 0 & year==`i'
		}
		
		* Generating a conflict onset variable
		gen onset_ACLED = 0
		
		* Replacing the conflict onset variable to 1 if number of years in peace is lower than 2
		by GID_1_encoded (year), sort: replace onset_ACLED = 1 if conflict_inc_ACLED==1 & peace_years[_n-1] >= 2 

		* Dropping intermerdiary variables
		drop _merge fatalities peace_years_ACLED
*/

*************************
*Cleaning the final data
*************************

****Setting the panel data
	* Dropping variables with no id
	drop if missing(GID_1_encoded)
	
****Drop regions with unbalanced observations across the years 
	by GID_1_encoded (year), sort: gen obs_count = _N
	tab GID_1 if obs_count < 33
	drop if obs_count < 33
	
	* xtset command for panel data regressions
	xtset GID_1_encoded year

****Labelling all variables to meaningful names for regression output
	label var GID_1_encoded "Unique code of the subnational region/province"
	label var GID_1 "Unique code of the subnational region/province"
	label var year "Year"
	label var onset "Onset of a new conflict"
	label var conflict_incidence "Conflict incidence"
	label var total_deaths "Number of deaths"
	label var GEO "Continental region"
	label var iso "Country's iso3c code"
	label var iso_encoded "Country's iso3c code"
	rename NAMES_STD Country
	label var Country "Country"
	label var peace_years "Number of years wihtout any conflict"
	label var MEAN_Level "Mean precipiation"		

****Display the number of conflict by GEO
	levelsof GEO, local(levels)
	foreach l of local levels {
	display "`l' Conflict incidences"
	qui sum conflict_incidence if GEO =="`l'"
	di r(mean)*r(N)
	display "`l' Conflict onsets"
	qui sum onset if GEO =="`l'"
	di r(mean)*r(N)
	}

****Drop Europe and Ocenia because there are too few number of conflicts
	drop if GEO =="Europe" | GEO=="Oceania"
	* Creating a dummy variable for every country
	tab GEO, gen(Continent_)

****Saving the dataset for regressions at the yearly level
	save regression_file_CHIRPS_precipitation, replace
