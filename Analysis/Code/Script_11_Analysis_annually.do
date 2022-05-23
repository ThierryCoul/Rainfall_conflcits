****Using the dataset for the regression analsyses
	use regression_file_annually, clear
	*use replication_file_annually, clear
	
	xtset GID_1_encoded year

****Hausman test
	xtreg conflict_incidence MEAN_Level, fe
	estimates store Fixed
	xtreg conflict_incidence MEAN_Level, re
	estimates store Random
	hausman Fixed Random
	

********************************************
* Table S3 Performing the summary statistics
********************************************
	outreg2 using "../../Manuscript/Summary_stat_month.doc", replace sum(log) keep(conflict_incidence onset MEAN_Level peace_years ///
		pop gnic lifexp ln_gnic ln_pop ln_lifexp)

*******************************************************
* Table 1 Model 1: Main regression at the yearly level
*******************************************************

**** Main estimates: Precipitation anomalies and endowment on conflict incidence and onset
	reghdfe conflict_incidence MEAN_Level, absorb(GID_1_encoded year) vce(cluster iso_encoded year)
	outreg2 using "../../Manuscript/Regression.doc", append ctitle(Model 1) label addtext(Year FE, YES, Region FE, YES)	

	reghdfe onset MEAN_Level, absorb(GID_1_encoded year) vce(cluster iso_encoded year)
	outreg2 using "../../Manuscript/Regression.doc", append ctitle(Model 1) label addtext(Year FE, YES, Region FE, YES)

*********************************************************************
*Table 2 - Model 2: heteregenous effect with respect ot income level
*********************************************************************

	reghdfe conflict_incidence c.MEAN_Level##c.ln_gnic, absorb(GID_1_encoded year) vce(cluster iso_encoded year)
	outreg2 using "../../Manuscript/Regression_by_income.doc", append ctitle(Conflict - "income regions") label addtext(Year FE, YES, Region FE, YES)

	reghdfe onset c.MEAN_Level##c.ln_gnic, absorb(GID_1_encoded year) vce(cluster iso_encoded year)
	outreg2 using "../../Manuscript/Regression_by_income.doc", append ctitle(Onset - "income regions") label addtext(Year FE, YES, Region FE, YES)

	reghdfe conflict_incidence c.MEAN_Level##c.ln_GNI_per_capita, absorb(GID_1_encoded year) vce(cluster iso_encoded year)
	outreg2 using "../../Manuscript/Regression_by_income.doc", append ctitle(Conflict - "income countries") label addtext(Year FE, YES, Region FE, YES)

	reghdfe onset c.MEAN_Level##c.ln_GNI_per_capita, absorb(GID_1_encoded year) vce(cluster iso_encoded year)
	outreg2 using "../../Manuscript/Regression_by_income.doc", append ctitle(Onset - "income countries") label addtext(Year FE, YES, Region FE, YES)

	
************************************************************
*Table S5: Regressions with alternative model specifications
************************************************************
	
**** Model 3: Precipitation on conflict incidence and onset without year dummies
	reghdfe conflict_incidence MEAN_Level, absorb(GID_1) vce(cluster iso_encoded year)
	outreg2 using "../../Manuscript/Regression_alternative_yearly.doc", replace ctitle(Model 3) label addtext(Year FE, NO, Region FE, YES)	

	reghdfe onset MEAN_Level, absorb(GID_1) vce(cluster iso_encoded year)
	outreg2 using "../../Manuscript/Regression_alternative_yearly.doc", append ctitle(Model 3) label addtext(Year FE, NO, Region FE, YES)

**** Model 4: Precipitation on conflict incidence and onset with random effects
	reghdfe conflict_incidence MEAN_Level, noabsorb vce(cluster iso_encoded year)
	outreg2 using "../../Manuscript/Regression_alternative_yearly.doc", append ctitle(Model 4) label addtext(Year FE, NO, Region FE, NO)	

	reghdfe onset MEAN_Level, noabsorb vce(cluster iso_encoded year)
	outreg2 using "../../Manuscript/Regression_alternative_yearly.doc", append ctitle(Model 4) label addtext(Year FE, NO, Region FE, NO)

**** Model 5: Precipitation on conflict incidence and onset with control vaiables
	sort GID_1_encoded year
	reghdfe conflict_incidence MEAN_Level L(1).peace_years ln_gnic ln_pop ln_lifexp, absorb(GID_1_encoded year) vce(cluster iso_encoded year)
	outreg2 using "../../Manuscript/Regression_alternative_yearly.doc", append ctitle(Model 5) keep(MEAN_Level L(1).peace_years ln_gnic ln_pop ln_lifexp) label addtext(Year FE, YES, Region FE, YES)
		
	reghdfe onset MEAN_Level L(1).peace_years ln_gnic ln_pop ln_lifexp, absorb(GID_1_encoded year) vce(cluster iso_encoded year)
	outreg2 using "../../Manuscript/Regression_alternative_yearly.doc", append ctitle(Model 5) keep(MEAN_Level L(1).peace_years ln_gnic ln_pop ln_lifexp) label addtext(Year FE, YES, Region FE, YES)

**** Model 6: Precipitation on conflict incidence and onset with regions that experienced at least one conflict
	*Creating a variable displaying conflict and onset incidence within regions
	bysort GID_1: egen conflict_variation= mean(conflict_incidence)
	bysort GID_1: egen onset_variation= mean(onset)
	
	reghdfe conflict_incidence MEAN_Level if conflict_variation > 0, absorb(GID_1_encoded year) vce(cluster iso_encoded year)
	outreg2 using "../../Manuscript/Regression_alternative_yearly.doc", append ctitle(Model 6) label addtext(Year FE, YES, Region FE, YES)	

	reghdfe onset MEAN_Level if onset_variation > 0, absorb(GID_1_encoded year) vce(cluster iso_encoded year)
	outreg2 using "../../Manuscript/Regression_alternative_yearly.doc", append ctitle(Model 6) label addtext(Year FE, YES, Region FE, YES)

**** Model 7: Precipitation on conflict incidence and onset in Africa
	reghdfe conflict_incidence MEAN_Level if GEO=="Africa", absorb(GID_1_encoded year) vce(cluster iso_encoded year)
	outreg2 using "../../Manuscript/Regression_alternative_yearly.doc", append ctitle(Model 7) label addtext(Year FE, YES, Region FE, YES)	

	reghdfe onset MEAN_Level if GEO=="Africa", absorb(GID_1_encoded year) vce(cluster iso_encoded year)
	outreg2 using "../../Manuscript/Regression_alternative_yearly.doc", append ctitle(Model 7) label addtext(Year FE, YES, Region FE, YES)

	
*****************************************************************
*Table S7 : Regressions with alternative model specifications (2)
*****************************************************************

**** Model 8: Taking the number of conflicts instead of conflict incidence as dependent variable
	nbreg number_of_conflict MEAN_Level i.year, vce(cluster iso_encoded)
	outreg2 using "../../Manuscript/Regression_alternative_yearly_2.doc", replace ctitle(Model 8) label addtext(Year FE, YES, Region FE, YES)	
	
**** Model 9: Logistic regression
	xtlogit conflict_incidence MEAN_Level i.year, fe
	outreg2 using "../../Manuscript/Regression_alternative_yearly_2.doc", append ctitle(Model 9 - Logit) keep(MEAN_Level) label  addtext(Time FE, YES, Region FE, YES)

	xtlogit onset  MEAN_Level i.year, fe
	outreg2 using "../../Manuscript/Regression_alternative_yearly_2.doc", append ctitle(Model 9 - Logit) keep(MEAN_Level) label  addtext(Time FE, YES, Region FE, YES)
	
**** Model 10: All types of conflicts
	reghdfe conflict_incidence_any MEAN_Level, absorb(GID_1_encoded year) vce(cluster iso_encoded year)
	outreg2 using "../../Manuscript/Regression_alternative_yearly_2.doc", append ctitle(Model 10 - All conflcits) label addtext(Year FE, YES, Month FE, YES,Region FE, YES)	

	reghdfe onset_any MEAN_Level, absorb(GID_1_encoded year) vce(cluster iso_encoded year)
	outreg2 using "../../Manuscript/Regression_alternative_yearly_2.doc", append ctitle(Model 10 - All conflcits) label addtext(Year FE, YES, Month FE, YES,Region FE, YES)
	
****  Model 11: Analysis using ACLED data - ACLED conflict data record are available from 1997
	reghdfe conflict_inc_ACLED MEAN_Level if year >=1997, absorb(GID_1_encoded year) vce(cluster iso_encoded year)
	outreg2 using "../../Manuscript/Regression_alternative_yearly_2.doc", append ctitle(Model 11  - ACLED conflicts) label addtext(Year FE, YES, Month FE, YES,Region FE, YES)
	
	reghdfe onset_ACLED MEAN_Level if year >=1997, absorb(GID_1_encoded year) vce(cluster iso_encoded year)
	outreg2 using "../../Manuscript/Regression_alternative_yearly_2.doc", append ctitle(Model 11  - ACLED conflicts) label addtext(Year FE, YES, Month FE, YES,Region FE, YES)

****  Model 12: Analysis at the country level
	collapse conflict_incidence MEAN_Level onset, by(iso_encoded year)
	
	xtset iso_encoded year
	reghdfe conflict_incidence MEAN_Level, absorb(iso_encoded year) vce(cluster year)
	outreg2 using "../../Manuscript/Regression_alternative_yearly_2.doc", append ctitle(Model 12 - country incidence) label addtext(Year FE, YES, Month FE, YES, Country FE, YES)

	reghdfe onset MEAN_Level, absorb(iso_encoded year) vce(cluster year)
	outreg2 using "../../Manuscript/Regression_alternative_yearly_2.doc", append ctitle(Model 12 - countryonset) label addtext(Year FE, YES, Month FE, YES, Country FE, YES)

**** Reload the dataset at the regional level
	use regression_file_annually, clear


	
*********************************************
*Table S9 : with lag values of precipitation
*********************************************

****  Model 13: Regressions with 1 lag variable
	sort GID_1_encoded year
	reghdfe conflict_incidence L(0/1).MEAN_Level, absorb(GID_1_encoded year) vce(cluster iso_encoded year)
	outreg2 using "../../Manuscript/Regression_lags_year.doc", replace ctitle(Model 13) label addtext(Year FE, YES, Region FE, YES)	

	reghdfe onset L(0/1).MEAN_Level, absorb(GID_1_encoded year) vce(cluster iso_encoded year)
	outreg2 using "../../Manuscript/Regression_lags_year.doc", append ctitle(Model 13) label addtext(Year FE, YES, Region FE, YES)

****  Model 14: Regressions with 1 lag variable as only variable
	reghdfe conflict_incidence L.MEAN_Level, absorb(GID_1_encoded year) vce(cluster iso_encoded year)
	outreg2 using "../../Manuscript/Regression_lags_year.doc", append ctitle(Model 14) label addtext(Year FE, YES, Region FE, YES)	

	reghdfe onset L.MEAN_Level, absorb(GID_1_encoded year) vce(cluster iso_encoded year)
	outreg2 using "../../Manuscript/Regression_lags_year.doc", append ctitle(Model 14) label addtext(Year FE, YES, Region FE, YES)

****  Model 15: Regressions with 10 lags observations
	reghdfe conflict_incidence L(0/10).MEAN_Level, absorb(GID_1_encoded year) vce(cluster iso_encoded year)
	outreg2 using "../../Manuscript/Regression_lags_year.doc", append ctitle(Model 15) label addtext(Year FE, YES, Region FE, YES)	

	reghdfe onset L(0/10).MEAN_Level, absorb(GID_1_encoded year) vce(cluster iso_encoded year)
	outreg2 using "../../Manuscript/Regression_lags_year.doc", append ctitle(Model 15) label addtext(Year FE, YES, Region FE, YES)
