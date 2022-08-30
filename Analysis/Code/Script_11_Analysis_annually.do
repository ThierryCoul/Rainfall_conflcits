****Using the dataset for the regression analsyses
	cd"../Output"
	use regression_file_annually, clear
	xtset
	spset

****Pre-estimation tests	
	*Hausman test without contol variables
	qui xtreg conflict_incidence MEAN_Level L(1).peace_years, fe
	estimates store Fixed
	qui xtreg conflict_incidence MEAN_Level L(1).peace_years, re
	estimates store Random
	hausman Fixed Random, sigmamore

	*Hausman test without contol variables
	qui xtreg onset_2 MEAN_Level L(1).peace_years, fe
	estimates store Fixed
	qui xtreg onset_2 MEAN_Level L(1).peace_years, re
	estimates store Random
	hausman Fixed Random

	*Hausman test with contol variables
	sort _ID year
	qui xtreg conflict_incidence MEAN_Level L(1).peace_years ln_gnic ln_pop ln_lifexp, fe
	estimates store Fixed
	qui xtreg conflict_incidence MEAN_Level L(1).peace_years ln_gnic ln_pop ln_lifexp, re
	estimates store Random
	hausman Fixed Random, sigmamore

	*Hausman test with contol variables
	sort _ID year
	qui xtreg onset_2 MEAN_Level L(1).peace_years ln_gnic ln_pop ln_lifexp, fe
	estimates store Fixed
	qui xtreg onset_2 MEAN_Level L(1).peace_years ln_gnic ln_pop ln_lifexp, re
	estimates store Random
	hausman Fixed Random	
	
********************************************
* Table S3 Performing the summary statistics
********************************************
	outreg2 using "../../Manuscript/Summary_stat_month.doc", replace sum(log) keep(conflict_incidence onset_2 MEAN_Level peace_years ///
		pop gnic lifexp ln_gnic ln_pop ln_lifexp)

*******************************************************
* Table 1 Model 1: Main regression at the yearly level
*******************************************************

**** Main estimates: Precipitation anomalies and endowment on conflict incidence and onset
	reghdfe conflict_incidence MEAN_Level L.peace_years, absorb(GID_1_encoded year) vce(cluster iso_encoded)
	outreg2 using "../../Manuscript/Regression.doc", append ctitle(Model 1) label addtext(Year FE, YES, Region FE, YES)	

	reghdfe onset_2 MEAN_Level L.peace_years, absorb(GID_1_encoded year) vce(cluster iso_encoded)
	outreg2 using "../../Manuscript/Regression.doc", append ctitle(Model 1) label addtext(Year FE, YES, Region FE, YES)

*********************************************************************
*Table 2 - Model 2: heteregenous effect with respect ot income level
*********************************************************************

	reghdfe conflict_incidence c.MEAN_Level##c.ln_gnic L.peace_years, absorb(GID_1_encoded year) vce(cluster iso_encoded)
	outreg2 using "../../Manuscript/Regression_by_income.doc", append ctitle(Conflict - "income regions") label addtext(Year FE, YES, Region FE, YES)

	reghdfe onset_2 c.MEAN_Level##c.ln_gnic L.peace_years, absorb(GID_1_encoded year) vce(cluster iso_encoded)
	outreg2 using "../../Manuscript/Regression_by_income.doc", append ctitle(onset_2 - "income regions") label addtext(Year FE, YES, Region FE, YES)

	reghdfe conflict_incidence c.MEAN_Level##c.ln_GNI_per_capita L.peace_years, absorb(GID_1_encoded year) vce(cluster iso_encoded)
	outreg2 using "../../Manuscript/Regression_by_income.doc", append ctitle(Conflict - "income countries") label addtext(Year FE, YES, Region FE, YES)

	reghdfe onset_2 c.MEAN_Level##c.ln_GNI_per_capita L.peace_years, absorb(GID_1_encoded year) vce(cluster iso_encoded)
	outreg2 using "../../Manuscript/Regression_by_income.doc", append ctitle(Onset - "income countries") label addtext(Year FE, YES, Region FE, YES)
	
************************************************************
*Table S5: Regressions with alternative model specifications
************************************************************
	
**** Model 3: Precipitation on conflict incidence and onset without year dummies
	reghdfe conflict_incidence MEAN_Level  L.peace_years, absorb(GID_1) vce(cluster iso_encoded)
	outreg2 using "../../Manuscript/Regression_alternative_yearly.doc", replace ctitle(Model 3) label addtext(Year FE, NO, Region FE, YES)	

	reghdfe onset_2 MEAN_Level  L.peace_years, absorb(GID_1) vce(cluster iso_encoded)
	outreg2 using "../../Manuscript/Regression_alternative_yearly.doc", append ctitle(Model 3) label addtext(Year FE, NO, Region FE, YES)

**** Model 4: Precipitation on conflict incidence and onset with random effects
	reghdfe conflict_incidence MEAN_Level  L.peace_years, noabsorb vce(cluster iso_encoded)
	outreg2 using "../../Manuscript/Regression_alternative_yearly.doc", append ctitle(Model 4) label addtext(Year FE, NO, Region FE, NO)	

	reghdfe onset_2 MEAN_Level  L.peace_years, noabsorb vce(cluster iso_encoded)
	outreg2 using "../../Manuscript/Regression_alternative_yearly.doc", append ctitle(Model 4) label addtext(Year FE, NO, Region FE, NO)

**** Model 5: Precipitation on conflict incidence and onset with control vaiables
	reghdfe conflict_incidence MEAN_Level L.peace_years  ln_gnic ln_pop ln_lifexp, absorb(GID_1_encoded year) vce(cluster iso_encoded)
	outreg2 using "../../Manuscript/Regression_alternative_yearly.doc", append ctitle(Model 5) keep(MEAN_Level L.peace_years  ln_gnic ln_pop ln_lifexp) label addtext(Year FE, YES, Region FE, YES)
		
	reghdfe onset_2 MEAN_Level L.peace_years ln_gnic ln_pop ln_lifexp, absorb(GID_1_encoded year) vce(cluster iso_encoded)
	outreg2 using "../../Manuscript/Regression_alternative_yearly.doc", append ctitle(Model 5) keep(MEAN_Level L.peace_years ln_gnic ln_pop ln_lifexp) label addtext(Year FE, YES, Region FE, YES)

**** Model 6: Precipitation on conflict incidence and onset with regions that experienced at least one conflict

	reghdfe conflict_incidence MEAN_Level L.peace_years if conflict_variation > 0, absorb(GID_1_encoded year) vce(cluster iso_encoded)
	outreg2 using "../../Manuscript/Regression_alternative_yearly.doc", append ctitle(Model 6) label addtext(Year FE, YES, Region FE, YES)	

	reghdfe onset_2 MEAN_Level L.peace_years if onset_variation > 0, absorb(GID_1_encoded year) vce(cluster iso_encoded)
	outreg2 using "../../Manuscript/Regression_alternative_yearly.doc", append ctitle(Model 6) label addtext(Year FE, YES, Region FE, YES)

**** Model 7: Precipitation on conflict incidence and onset in Africa
	reghdfe conflict_incidence MEAN_Level L.peace_years if GEO=="Africa", absorb(GID_1_encoded year) vce(cluster iso_encoded)
	outreg2 using "../../Manuscript/Regression_alternative_yearly.doc", append ctitle(Model 7) label addtext(Year FE, YES, Region FE, YES)	

	reghdfe onset_2 MEAN_Level if GEO=="Africa", absorb(GID_1_encoded year) vce(cluster iso_encoded)
	outreg2 using "../../Manuscript/Regression_alternative_yearly.doc", append ctitle(Model 7) label addtext(Year FE, YES, Region FE, YES)

	
*****************************************************************
*Table S7 : Regressions with alternative model specifications (2)
*****************************************************************

*** Model 8: Taking the number of conflicts instead of conflict incidence as dependent variable
	qui nbreg number_of_conflict MEAN_Level L.peace_years i.GID_1_encoded i.year, vce(cluster iso_encoded)  iterate(10)
	outreg2 using "../../Manuscript/Regression_alternative_yearly_2.doc", replace ctitle(Model 8) keep(MEAN_Level L.peace_years) e(r2_p) label addtext(Time FE, YES, Region FE, YES)	
	
**** Model 9: Logistic regression
*https://www.statalist.org/forums/forum/general-stata-discussion/general/70609-fixed-effects-logit-standard-errors
	qui logit conflict_incidence MEAN_Level L.peace_years i.GID_1_encoded i.year if conflict_variation >0, vce(cluster iso_encoded) noconstant
	outreg2 using "../../Manuscript/Regression_alternative_yearly_2.doc", append ctitle(Model 9 - Logit) keep(MEAN_Level L.peace_years) e(r2_p) label addtext(Time FE, YES, Region FE, YES)

	qui logit onset_2 MEAN_Level L.peace_years i.GID_1_encoded i.year if onset_variation >0, vce(cluster iso_encoded) noconstant
	outreg2 using "../../Manuscript/Regression_alternative_yearly_2.doc", append ctitle(Model 9 - Logit) keep(MEAN_Level L.peace_years) e(r2_p) label addtext(Time FE, YES, Region FE, YES)


**** Model 10: Multilevel model linear regression with control variables
	xtmixed conflict_incidence MEAN_Level L.peace_years ln_gnic ln_pop ln_lifexp || iso_encoded:, mle nolog covariance(unstructured)
	outreg2 using "../../Manuscript/Regression_alternative_yearly_2.doc", append  ctitle(Model 10 - Hierarchical linear model with controls) label addtext(Time FE, NO, Region FE, NO)
	
	xtmixed onset_2 MEAN_Level L.peace_years ln_gnic ln_pop ln_lifexp || iso_encoded:, mle nolog covariance(unstructured)
	outreg2 using "../../Manuscript/Regression_alternative_yearly_2.doc", append ctitle(Model 10 - Hierarchical linear model with controls) label addtext(Time FE, NO, Region FE, NO)	


	
	
**** Model 11: Spatial Auto-regressive Model (SAR)
	*Creating a spatial weight matrix
	spmatrix create contiguity M if year==2000, normalize(row) replace
	
	*Performing the regressions
	spxtregress conflict_incidence MEAN_Level L1_peace_years if conflict_variation > 0, fe dvarlag(M) errorlag(M) force
	outreg2 using "../../Manuscript/Regression_alternative_yearly_2.doc", append ctitle(Model 11 - SAR) keep(MEAN_Level) label addtext(Time FE, YES, Region FE, NO)

	spxtregress onset_2 MEAN_Level L1_peace_years if conflict_variation > 0, fe dvarlag(M) errorlag(M) force
	outreg2 using "../../Manuscript/Regression_alternative_yearly_2.doc", append ctitle(Model 11 - SAR) keep(MEAN_Level) label addtext(Time FE, YES, Region FE, NO)

**** Model 11: Block bootstrap standard-errors
	bootstrap, reps(500) cluster(iso_encoded) idcluster(IDD) group(_ID) seed(10): xtreg conflict_incidence MEAN_Level L.peace_years i.year, fe vce(r)
	outreg2 using "../../Manuscript/Regression_alternative_yearly_2.doc", append ctitle(Model 12)  label addtext(Time FE, YES, Region FE, YES)
	
	bootstrap, reps(500) cluster(iso_encoded) idcluster(IDD) group(_ID) seed(10): xtreg onset_2 MEAN_Level L.peace_years i.year, fe vce(r)
	outreg2 using "../../Manuscript/Regression_alternative_yearly_2.doc", append ctitle(Model 12) label addtext(Time FE, YES, Region FE, YES)
			

	
*****************************************************************
*Table S9 : Regressions with alternative conflict definition
*****************************************************************
	
**** Model 14: All types of conflicts
	reghdfe conflict_incidence_any MEAN_Level  L.peace_years, absorb(GID_1 year)  vce(cluster iso_encoded)
	outreg2 using "../../Manuscript/Regression_alternative_yearly_3.doc", replace ctitle(Model 13 - All types of conflict) label addtext(Time FE, YES, Region FE, YES)	

	reghdfe onset_any_2 MEAN_Level  L.peace_years, absorb(GID_1 year)  vce(cluster iso_encoded)
	outreg2 using "../../Manuscript/Regression_alternative_yearly_3.doc", append ctitle(Model 13 - All types of conflict) label addtext(Time FE, YES, Region FE, YES)
	
****  Model 15: Analysis using ACLED data - ACLED conflict data record are available from 1997
	reghdfe conflict_inc_ACLED MEAN_Level  L.peace_years if year >=1997, absorb(GID_1 year)  vce(cluster iso_encoded)
	outreg2 using "../../Manuscript/Regression_alternative_yearly_3.doc", append ctitle(Model 14 - ACLED conflicts) label addtext(Time FE, YES, Region FE, YES)
	
	reghdfe onset_ACLED MEAN_Level  L.peace_years if year >=1997, absorb(GID_1 year)  vce(cluster iso_encoded)
	outreg2 using "../../Manuscript/Regression_alternative_yearly_3.doc", append ctitle(Model 14  - ACLED conflicts) label addtext(Time FE, YES, Region FE, YES)
	
****  Model 16: Analysis at the country level
	collapse (mean) conflict_incidence MEAN_Level (firstnm) iso (min) onset_2 peace_years, by(iso_encoded year)
	xtset iso_encoded year

	reghdfe conflict_incidence MEAN_Level  L.peace_years, absorb(iso_encoded year)
	outreg2 using "../../Manuscript/Regression_alternative_yearly_3.doc", append ctitle(Model 15 - country incidence) label addtext(Time FE, YES, Country FE, YES)

	reghdfe onset_2 MEAN_Level  L.peace_years, absorb(iso_encoded year)
	outreg2 using "../../Manuscript/Regression_alternative_yearly_3.doc", append ctitle(Model 15 - country onset) label addtext(Time FE, YES, Country FE, YES)

**** Reloading the data at the regional level
	use regression_file_annually, clear

	

*****************************************************
*Table S10 : with 5 years defintion of conflict onset
*****************************************************

reghdfe onset_5 MEAN_Level  L.peace_years, absorb(iso_encoded year)
outreg2 using "../../Manuscript/Regression_alternative_onset.doc", append ctitle(Model 1 - annually) label addtext(Time FE, YES, Country FE, YES)
	
	
*********************************************
*Table S12 : with lag values of precipitation
*********************************************

****  Model 15: Regressions with 1 lag variable
	sort _ID year
	reghdfe conflict_incidence L(0/1).MEAN_Level  L.peace_years, absorb(GID_1_encoded year) vce(cluster iso_encoded)
	outreg2 using "../../Manuscript/Regression_lags_year.doc", replace ctitle(Model 16) label addtext(Year FE, YES, Region FE, YES)	

	reghdfe onset_2 L(0/1).MEAN_Level  L.peace_years, absorb(GID_1_encoded year) vce(cluster iso_encoded)
	outreg2 using "../../Manuscript/Regression_lags_year.doc", append ctitle(Model 16) label addtext(Year FE, YES, Region FE, YES)

****  Model 16: Regressions with 1 lag variable as only variable
	reghdfe conflict_incidence L.MEAN_Level  L.peace_years, absorb(GID_1_encoded year) vce(cluster iso_encoded)
	outreg2 using "../../Manuscript/Regression_lags_year.doc", append ctitle(Model 17) label addtext(Year FE, YES, Region FE, YES)	

	reghdfe onset_2 L.MEAN_Level  L.peace_years, absorb(GID_1_encoded year) vce(cluster iso_encoded)
	outreg2 using "../../Manuscript/Regression_lags_year.doc", append ctitle(Model 17) label addtext(Year FE, YES, Region FE, YES)

****  Model 17: Regressions with 10 lags observations
	reghdfe conflict_incidence L(0/10).MEAN_Level  L.peace_years, absorb(GID_1_encoded year) vce(cluster iso_encoded)
	outreg2 using "../../Manuscript/Regression_lags_year.doc", append ctitle(Model 18) label addtext(Year FE, YES, Region FE, YES)	

	reghdfe onset_2 L(0/10).MEAN_Level  L.peace_years, absorb(GID_1_encoded year) vce(cluster iso_encoded)
	outreg2 using "../../Manuscript/Regression_lags_year.doc", append ctitle(Model 18) label addtext(Year FE, YES, Region FE, YES)
