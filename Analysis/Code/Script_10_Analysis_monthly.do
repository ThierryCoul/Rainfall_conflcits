****Loading the data
	use regression_file_monthly, clear
	xtset GID_1_encoded time_id
	
****Hausman test
	xtreg conflict_incidence MEAN_Level, fe
	estimates store Fixed
	xtreg conflict_incidence MEAN_Level, re
	estimates store Random
	hausman Fixed Random
	
********************************************
* Table S3 Performing the summary statistics
********************************************
	outreg2 using "../../Manuscript/Summary_stat_month.doc", replace sum(log) keep(conflict_incidence ///
		onset MEAN_Level peace_years ln_gnic ln_pop ln_lifexp gnic pop lifexp)

*******************************************************
* Table 1 Model 1: Main regression at the monthly level
*******************************************************

**** Precipitation on conflict incidence and onset
	reghdfe conflict_incidence MEAN_Level, absorb(GID_1 time_id)  vce(cluster iso_encoded time_id)
	outreg2 using "../../Manuscript/Regression.doc", replace ctitle(Model 1) label addtext(Time FE, YES, Region FE, YES)
	
	reghdfe onset MEAN_Level, absorb(GID_1 time_id)  vce(cluster iso_encoded time_id)
	outreg2 using "../../Manuscript/Regression.doc", append ctitle(Model 1) label addtext(Time FE, YES, Region FE, YES)
	
*********************************************************************
*Table 2 - Model 2: heteregenous effect with respect ot income level
*********************************************************************


	*Regressions with interaction of regional income 
	reghdfe conflict_incidence c.MEAN_Level##c.ln_gnic, absorb(GID_1 time_id)  vce(cluster iso_encoded time_id)
	outreg2 using "../../Manuscript/Regression_by_income.doc", replace ctitle(Conflict - "income regions") label addtext(Time FE, YES,Region FE, YES)

	reghdfe onset c.MEAN_Level##c.ln_gnic, absorb(GID_1 time_id)  vce(cluster iso_encoded time_id)
	outreg2 using "../../Manuscript/Regression_by_income.doc", append ctitle(Onset - "income regions") label addtext(Time FE, YES,Region FE, YES)

	*Regressions with interaction of national income 
	reghdfe conflict_incidence c.MEAN_Level##c.ln_GNI_per_capita, absorb(GID_1 time_id)  vce(cluster iso_encoded time_id)
	outreg2 using "../../Manuscript/Regression_by_income.doc", append ctitle(Conflict - "income countries") label addtext(Time FE, YES,Region FE, YES)

	reghdfe onset c.MEAN_Level##c.ln_GNI_per_capita, absorb(GID_1 time_id) vce(cluster iso_encoded time_id)
	outreg2 using "../../Manuscript/Regression_by_income.doc", append ctitle(Onset - "income countries") label addtext(Time FE, YES,Region FE, YES)


************************************************************
*Table S4: Regressions with alternative model specifications
************************************************************
	
**** Model 3: Precipitation on conflict incidence and onset without time dummies
	reghdfe conflict_incidence MEAN_Level, absorb(GID_1) vce(cluster iso_encoded time_id)
	outreg2 using "../../Manuscript/Regression_alternative_monthly.doc", replace ctitle(Model 3) label addtext(Time FE, NO, Region FE, YES)	

	reghdfe onset MEAN_Level, absorb(GID_1) vce(cluster iso_encoded time_id)
	outreg2 using "../../Manuscript/Regression_alternative_monthly.doc", append ctitle(Model 3) label addtext(Time FE, NO, Region FE, YES)

**** Model 4: Precipitation on conflict incidence and onset with random effects
	reghdfe conflict_incidence MEAN_Level, noabsorb vce(cluster iso_encoded time_id)
	outreg2 using "../../Manuscript/Regression_alternative_monthly.doc", append ctitle(Model 4) label addtext(Time FE, NO, Region FE, NO)	

	reghdfe onset MEAN_Level, noabsorb vce(cluster iso_encoded time_id)
	outreg2 using "../../Manuscript/Regression_alternative_monthly.doc", append ctitle(Model 4) label addtext(Time FE, NO, Region FE, NO)

**** Model 5: Precipitation on conflict incidence and onset with control vaiables
	reghdfe conflict_incidence MEAN_Level L(1).peace_years ln_gnic ln_pop ln_lifexp, absorb(GID_1_encoded time_id)  vce(cluster iso_encoded time_id)
	outreg2 using "../../Manuscript/Regression_alternative_monthly.doc", append ctitle(Model 5) keep(MEAN_Level L(1).peace_years ln_gnic ln_pop ln_lifexp) label addtext(Time FE, YES,Region FE, YES)
		
	reghdfe onset MEAN_Level L(1).peace_years ln_gnic ln_pop ln_lifexp, absorb(GID_1_encoded time_id) vce(cluster iso_encoded time_id)
	outreg2 using "../../Manuscript/Regression_alternative_monthly.doc", append ctitle(Model 5) keep(MEAN_Level L(1).peace_years ln_gnic ln_pop ln_lifexp) label addtext(Time FE, YES,Region FE, YES)

**** Model 6: Precipitation on conflict incidence and onset with regions that experienced at least one conflict
	*Creating a variable displaying conflict and onset incidence within regions
	bysort GID_1: egen conflict_variation= mean(conflict_incidence)
	bysort GID_1: egen onset_variation= mean(onset)
	
	reghdfe conflict_incidence MEAN_Level if conflict_variation > 0, absorb(GID_1 time_id) vce(cluster iso_encoded time_id)
	outreg2 using "../../Manuscript/Regression_alternative_monthly.doc", append ctitle(Model 6) keep(MEAN_Level) label addtext(Time FE, YES,Region FE, YES)
	
	reghdfe onset MEAN_Level if onset_variation > 0, absorb(GID_1 time_id)  vce(cluster iso_encoded time_id)
	outreg2 using "../../Manuscript/Regression_alternative_monthly.doc", append ctitle(Model 6) keep(MEAN_Level) label addtext(Time FE, YES,Region FE, YES)

**** Model 7: Precipitation on conflict incidence and onset in Africa
	reghdfe conflict_incidence MEAN_Level if GEO=="Africa", absorb(GID_1 time_id)  vce(cluster iso_encoded time_id)
	outreg2 using "../../Manuscript/Regression_alternative_monthly.doc", append ctitle(Model 5) keep(MEAN_Level) label addtext(Time FE, YES,Region FE, YES)
	
	reghdfe onset MEAN_Level if GEO=="Africa", absorb(GID_1 time_id)  vce(cluster iso_encoded time_id)
	outreg2 using "../../Manuscript/Regression_alternative_monthly.doc", append ctitle(Model 5) keep(MEAN_Level) label addtext(Time FE, YES,Region FE, YES)

	
*****************************************************************
*Table S6 : Regressions with alternative model specifications (2)
*****************************************************************

**** Model 8: Taking the number of conflicts instead of conflict incidence as dependent variable
	nbreg number_of_conflict MEAN_Level i.time_id, vce(cluster iso_encoded)
	outreg2 using "../../Manuscript/Regression_alternative_monthly_2.doc", replace ctitle(Model 8) keep(MEAN_Level) label addtext(Time FE, YES, Region FE, YES)	
	
**** Model 9: Logistic regression
	xtlogit conflict_incidence MEAN_Level i.year i.month, fe
	outreg2 using "../../Manuscript/Regression_alternative_monthly_2.doc", append ctitle(Model 9 - Logit) keep(MEAN_Level) label  addtext(Time FE, YES, Region FE, YES)

	xtlogit onset  MEAN_Level i.year i.month, fe
	outreg2 using "../../Manuscript/Regression_alternative_monthly_2.doc", append ctitle(Model 9 - Logit) keep(MEAN_Level) label  addtext(Time FE, YES, Region FE, YES)
	
**** Model 10: All types of conflicts
	reghdfe conflict_incidence_any MEAN_Level, absorb(GID_1 time_id)  vce(cluster iso_encoded time_id)
	outreg2 using "../../Manuscript/Regression_alternative_monthly_2.doc", append ctitle(Model 10 - All conflcits) label addtext(Time FE, YES, Region FE, YES)	

	reghdfe onset_any MEAN_Level, absorb(GID_1 time_id)  vce(cluster iso_encoded time_id)
	outreg2 using "../../Manuscript/Regression_alternative_monthly_2.doc", append ctitle(Model 10 - All conflcits) label addtext(Time FE, YES, Region FE, YES)
	
****  Model 11: Analysis using ACLED data - ACLED conflict data record are available from 1997
	reghdfe conflict_inc_ACLED MEAN_Level if year >=1997, absorb(GID_1 time_id)  vce(cluster iso_encoded time_id)
	outreg2 using "../../Manuscript/Regression_alternative_monthly_2.doc", append ctitle(Model 11 - ACLED conflicts) label addtext(Time FE, YES, Region FE, YES)
	
	reghdfe onset_ACLED MEAN_Level if year >=1997, absorb(GID_1 time_id)  vce(cluster iso_encoded time_id)
	outreg2 using "../../Manuscript/Regression_alternative_monthly_2.doc", append ctitle(Model 11  - ACLED conflicts) label addtext(Time FE, YES, Region FE, YES)
	
****  Model 12: Analysis at the country level
	collapse conflict_incidence MEAN_Level onset (firstnm) iso, by(iso_encoded year month time_id)
	xtset iso_encoded time_id

	reghdfe conflict_incidence MEAN_Level, absorb(iso_encoded time_id) vce(cluster time_id)
	outreg2 using "../../Manuscript/Regression_alternative_monthly_2.doc", append ctitle(Model 12 - country incidence) label addtext(Time FE, YES, Country FE, YES)

	reghdfe onset MEAN_Level, absorb(iso_encoded time_id) vce(cluster time_id)
	outreg2 using "../../Manuscript/Regression_alternative_monthly_2.doc", append ctitle(Model 12 - country onset) label addtext(Time FE, YES, Country FE, YES)

**** Reloading the data at the regional level
	use regression_file_monthly, clear

*******************************************************************	
*Figure 1: Regressions with leads and lags of rainfall observations
*******************************************************************
	*Precipitation on conflict incidence and onset with 6 months lead and lag variables
	sort GID_1_encoded time_id

	reghdfe conflict_incidence F(6/1).MEAN_Level L(0/6).MEAN_Level, absorb(GID_1 time_id)  vce(cluster iso_encoded time_id)
	estimates store Inc
	reghdfe onset F(6/1).MEAN_Level L(0/6).MEAN_Level, absorb(GID_1 time_id)  vce(cluster iso_encoded time_id)
	estimates store Ons
	coefplot Inc, bylabel( Conflict incidence (m)) ///
		   || Ons, bylabel(Conflict onset (m)) ///
		   ||, drop(_cons) xline(0) levels(95 90) ///
		   xlabel(-0.000005 "-0.0005%" 0 "0"  0.000005 "0.0005%", labsize(vsmall)) ///
		    coeflabels(L.MEAN_Level = "Rainfall (m-1)" L2.MEAN_Level = "Rainfall (m-2)" ///
			L3.MEAN_Level = "Rainfall (m-3)" L4.MEAN_Level = "Rainfall (m-4)" ///
			L5.MEAN_Level = "Rainfall (m-5)" L6.MEAN_Level = "Rainfall (m-6)" ///
			F.MEAN_Level = "Rainfall (m+1)" F2.MEAN_Level = "Rainfall (m+2)" ///
			F3.MEAN_Level = "Rainfall (m+3)" F4.MEAN_Level = "Rainfall (m+4)" ///
			F5.MEAN_Level = "Rainfall (m+5)" F6.MEAN_Level = "Rainfall (m+6)" ///
			MEAN_Level = "Rainfall (m)", labsize(small))
	
********************************************************************
*Figure S2: Regressions with leads and lags of rainfall observations
********************************************************************
	* Precipitation on conflict incidence and onset with 2 months lead and lag variables
	sort GID_1_encoded time_id

	reghdfe conflict_incidence F(2/1).MEAN_Level L(0/2).MEAN_Level, absorb(GID_1 time_id)  vce(cluster iso_encoded time_id)
	estimates store Inc
	reghdfe onset F(2/1).MEAN_Level L(0/2).MEAN_Level, absorb(GID_1 time_id)  vce(cluster iso_encoded time_id)
	estimates store Ons
	coefplot Inc, bylabel( Conflict incidence (m)) ///
		   || Ons, bylabel(Conflict onset (m)) ///
		   ||, drop(_cons) xline(0) levels(95 90) ///
		   xlabel(-0.000005 "-0.0005%" 0 "0"  0.000005 "0.0005%", labsize(vsmall)) ///
		    coeflabels(L.MEAN_Level = "Rainfall (m-1)" L2.MEAN_Level = "Rainfall (m-2)" ///
			F.MEAN_Level = "Rainfall (m+1)" F2.MEAN_Level = "Rainfall (m+2)" ///
			MEAN_Level = "Rainfall (m)", labsize(small))
	
*************************************************************************
*Data for Figure 2: Impact of rainfall on conflict incidence per regions*
*************************************************************************

****Loading the data
	use regression_file_monthly, clear

****Keep regions where at least one conflict occured
	bysort iso_encoded: egen conflict_variation= mean(conflict_incidence)
	keep if conflict_variation > 0

	gen xb = .
	gen z = .
	gen p_value = .
	egen id = group(GID_1_encoded) 
	sum id
	loc rmax = r(max)
	forvalues n = 1/`rmax' {
		di `n'
		qui reg conflict_incidence MEAN_Level i.year i.month if id == `n', vce(r)
		qui replace xb =  _b[MEAN_Level] if id == `n'
		qui replace z = xb / _se[MEAN_Level]
		qui replace p_value = 2*normal(-abs(z))
		}

	keep if xb < .
	keep xb z p_value iso GID_1
	duplicates drop
	export excel "Conflict_avoided.xlsx", replace firstrow(variables)

**** Reloading the data at the regional level
	use regression_file_monthly, clear

	
	
*********************************************
*Table S8 : with lag values of precipitation
*********************************************
	sort GID_1_encoded time_id
	reghdfe conflict_incidence MEAN_Level, absorb(GID_1_encoded time_id) vce(cluster iso_encoded time_id)
	outreg2 using "../../Manuscript/Regression_lags_month.doc", replace ctitle(Model 13) label addtext(Year FE, YES, Region FE, YES)	

	reghdfe onset MEAN_Level, absorb(GID_1_encoded year) vce(cluster iso_encoded time_id)
	outreg2 using "../../Manuscript/Regression_lags_month.doc", append ctitle(Model 13) label addtext(Year FE, YES, Region FE, YES)

	reghdfe conflict_incidence L.MEAN_Level, absorb(GID_1_encoded time_id) vce(cluster iso_encoded time_id)
	outreg2 using "../../Manuscript/Regression_lags_month.doc", append ctitle(Model 14) label addtext(Year FE, YES, Region FE, YES)	

	reghdfe onset L.MEAN_Level, absorb(GID_1_encoded year) vce(cluster iso_encoded time_id)
	outreg2 using "../../Manuscript/Regression_lags_month.doc", append ctitle(Model 14) label addtext(Year FE, YES, Region FE, YES)	

	reghdfe conflict_incidence L(0/11).MEAN_Level, absorb(GID_1_encoded time_id) vce(cluster iso_encoded time_id)
	outreg2 using "../../Manuscript/Regression_lags_month.doc", append ctitle(Model 15) label addtext(Year FE, YES, Region FE, YES)	

	reghdfe onset L(0/11).MEAN_Level, absorb(GID_1_encoded year) vce(cluster iso_encoded time_id)
	outreg2 using "../../Manuscript/Regression_lags_month.doc", append ctitle(Model 15) label addtext(Year FE, YES, Region FE, YES)
