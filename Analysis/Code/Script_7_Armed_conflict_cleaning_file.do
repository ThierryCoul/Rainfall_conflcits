global wd "Thierry_MAC/Analysis/Output"
cd "$wd"

*************************************************
* Importing the conflicts data from UCDP 
*************************************************

**** Data source: https://ucdp.uu.se/downloads/****
**** Data name: UCDP Georeferenced Event Dataset (GED) Global version 21.1 
	
**** Downloading the UCDP dataset
	copy https://ucdp.uu.se/downloads/ged/ged211-dta.zip ged211-dta.zip

**** Unzippinig the file and erase the zip file
	unzipfile ged211-dta.zip
	erase ged211-dta.zip

**** Importing the UCDP data joined with the gadm dataset
	import excel "GID_1_joined_UCDP.xlsx", clear firstrow
	* Saving the id of the intersection file
		keep id year GID_1
		save "../Temporary/GID_1_intersect_UCDP.dta", replace

**** Using the conflict file with more meaninfull variable names
	use "../Input/ged211-dta/ged211.dta", clear

	*Destring the identifiers for the merging
		destring year, replace
		destring id, replace
	*Merging the two conflicts dataset
		merge 1:1 id year using "../Temporary/GID_1_intersect_UCDP.dta"
	
**** Keeping useful variables
	keep id year active_year type_of_violence conflict_new_id conflict_name dyad_new_id dyad_name side_a side_a_new_id side_b side_b_new_id region date_prec date_start date_end deaths_a deaths_b deaths_civilians best GID_1
	rename id id_conflict
	label var active_year "1-the event belongs to an active conflict/dyad/actor-year 0-otherwise"
	label var type_of_violence "1-state-based conflict 2-non-state conflict 3-one-sided violence"
	label var conflict_new_id "Conflict id"
	label var conflict_name "conflict_name"
	label var dyad_new_id "id of the oppositions in the conflict"
	label var dyad_name "name of the oppositions in the conflict"
	label var side_a_new_id "id of the side in conflict"
	label var side_a "name of the side in conflict"
	label var side_b_new_id "id of the side in conflict"
	label var side_b "name of the side in conflict"
	label var region "Africa-Americas-Asia-Europe-Middle East"
	rename date_prec date_precision
	label var date_precision "1-Exact_date 2-range_of_2-6_days 3-week_is_known 4-range_of_8-30_day_ranges 5_range_>1months"
	label var date_start "Begining of the conflict"
	label var date_end "End of the conflict"
	label var deaths_a "Number of deaths from side a"
	label var deaths_b "Number of deaths from side b"
	label var deaths_civilians "Number of deaths of civilians"
	rename best total_deaths
	label var total_deaths "Total number of deaths"
	gen month = substr(date_start,6,2)
	label var month "month_conflict_start"
	gen day = substr(date_start,9,2)
	
**** Destring variables potentially necessary for the regression analyses
	destring active_year month type_of_violence conflict_new_id dyad_new_id side_a_new_id side_b_new_id date_precision deaths_a deaths_b deaths_civilians total_deaths day, replace

**** Saving the file
	save "Armed_conflicts_UCDP.dta", replace

	

*************************************************
* Importing ACLED armed conflict csv to Stata
*************************************************

cd "$wd"
cd "../Output"
****Importing the ACLED dataset
	*The ACLED need to be downloaded (and set in the input file) manually from https://acleddata.com/data-export-tool/
	import delimited "../input/Armed_conflicts_ACLED.csv", clear delimiters(";") varnames(1)
	split event_date
	rename event_date1 event_date_day
	rename event_date2 event_date_month
	rename event_date3 event_date_year
	gen month= 1
	replace month = 2 if event_date_month=="February"
	replace month = 3 if event_date_month=="March"
	replace month = 4 if event_date_month=="April"
	replace month = 5 if event_date_month=="May"
	replace month = 6 if event_date_month=="June"
	replace month = 7 if event_date_month=="July"
	replace month = 8 if event_date_month=="August"
	replace month = 9 if event_date_month=="September"
	replace month = 10 if event_date_month=="October"
	replace month = 11 if event_date_month=="November"
	replace month = 12 if event_date_month=="December"

	save "Armed_conflicts_ACLED.dta", replace
