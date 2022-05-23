global wd "Thierry_MAC/Analysis/Output"
cd "$wd"

*************************************************
* Importing csv of human development index from csv
*************************************************

cd "../Output"
****Importing the HDI dataset
	*The SHDI files need to be downloaded (and inserted in the input folder) manually from: https://globaldatalab.org/
	import excel "GID_1_X_GDL_id.xlsx", clear firstrow 
	drop shdi
	gen GID_0 = substr(GID_1,1,3)
	drop if missing(GID_1)
	save "HDI_data.dta", replace

****Creating a cross-sectional data for each year to merge it with the GADM map id
	forvalues i=1990(1)2019{
	import delimited "../Input/SHDI-SGDI-Total 5.0.csv", clear varnames(1)
	rename gdlcode GDLcode
	drop if year !=`i'
	*Mering the cross-sectionnal year with various keys of GID_1 file
		merge 1:m GDLcode using HDI_data
		drop if GDLcode ==" " & _merge==2
		drop if GDLcode =="NA" & _merge==2
		drop if GDLcode =="" & _merge==2
		drop if region=="Total"
	*These are polygons where the no centroids fall
		drop if _merge==1
	*These are the polygons where there is no calculations from SHDI
		drop if _merge==2
	*drop duplicates
		duplicates drop GID_1 GDLcode shdi, force
		save  GADM__GID`i', replace
	}

****Creating a panel data from the different crosssectional data
	local allfiles : dir . files "GADM__GID*"
	display `allfiles'
	append using `allfiles', force

****Drop observations that appears in double
	duplicates drop GDLcode GID_1 year, force

****Erasing the intermediairy files
	forvalues i=1990(1)2019{
	erase GADM__GID`i'.dta
	}

	drop _merge

****Clean the variables to be kept in the analysis
	destring pop, replace
	sum pop

****Colapsing the data at the GID_1 level
	collapse (mean) gnic pop lifexp, by(GID_1 year)

	label var gnic "GNI per capita in thousands of Dollards"
	label var pop "Population in thousands"
	label var lifexp "Average life expectancy"

	save "HDI_data.dta", replace

*************************************************
* Importing excel GNI per capita from World Bank
*************************************************	
	
****Downloading the GNI per capita data (World Bank: GNI per capita, PPP (constant 2017 international $))
	copy "https://api.worldbank.org/v2/en/indicator/NY.GNP.PCAP.PP.KD?downloadformat=excel" "../Temporary/GNI_per_capita.xls", replace

****Importing the data to stata
	import excel "../Temporary/GNI_per_capita.xls", clear sheet("Data") cellrange(A4)

****Destringing numeric values
	destring *, replace

****Displaying variables with numeric values
	ds, has(type numeric)

****Changing the value of the first row of numeric variable
	ds, has(type numeric)
	foreach var in `r(varlist)' {
		tostring `var', replace force
		replace `var' = "gni_per_capita" + `var' in 1
		}

****Replacing the variable name with first the row
	autorename *, row(1)

****destringing numeric values
	destring *, replace

****Keeping useful variables
	keep countrycode gni_per_capita*

****Reshaping dataset from wide to long
	reshape long gni_per_capita, i(countrycode) j(year)

****Renaming variables
	rename countrycode iso
	rename gni_per_capita GNI_per_capita

****Saving the GNI_per_capita data
	save GNI_per_capita_country, replace

****Replacing intermediary file
	erase "../Temporary/GNI_per_capita.xls"
