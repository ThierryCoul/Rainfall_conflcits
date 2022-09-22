****Using the dataset for the regression analsyses
	cd"../Output"
	use regression_file_annually, clear
	xtset
	spset

****Pre-estimation tests	
	*Conflict incidence - Hausman test without contol variables (Table S29)
	sort _ID year
	qui xtreg conflict_incidence MEAN_Level L(1).peace_years, fe
	estimates store Fixed
	qui xtreg conflict_incidence MEAN_Level L(1).peace_years, re
	estimates store Random
	hausman Fixed Random, sigmamore

	*Conflict incidence - Hausman test with contol variables (Table S30)
	sort _ID year
	qui xtreg conflict_incidence MEAN_Level L(1).peace_years ln_gnic ln_pop ln_lifexp, fe
	estimates store Fixed
	qui xtreg conflict_incidence MEAN_Level L(1).peace_years ln_gnic ln_pop ln_lifexp, re
	estimates store Random
	hausman Fixed Random, sigmamore

	*Conflict onset - Hausman test without contol variables (Table S31)
	sort _ID year
	qui xtreg onset_2 MEAN_Level L(1).peace_years if year >1990, fe
	estimates store Fixed
	qui xtreg onset_2 MEAN_Level L(1).peace_years if year >1990, re
	estimates store Random
	hausman Fixed Random
	
	*Conflict onset - Hausman test with contol variables (Table S32)
	sort _ID year
	qui xtreg onset_2 MEAN_Level L(1).peace_years ln_gnic ln_pop ln_lifexp if year >1990, fe
	estimates store Fixed
	qui xtreg onset_2 MEAN_Level L(1).peace_years ln_gnic ln_pop ln_lifexp if year >1990, re
	estimates store Random
	hausman Fixed Random	
	
********************************************
* Table S3 Performing the summary statistics
********************************************
	outreg2 using "../../Manuscript/Summary_stat_annual.doc", replace sum(log) keep(conflict_incidence onset_2 MEAN_Level peace_years ///
		pop gnic lifexp ln_gnic ln_pop ln_lifexp)

*******************************************************
* Table 1 Model 1: Main regression at the yearly level
*******************************************************
**** Main estimates: Impact of precipitation on conflict incidence and onset
	reghdfe conflict_incidence MEAN_Level L.peace_years, absorb(_ID year) vce(cluster iso_encoded)
	outreg2 using "../../Manuscript/Regression.doc", append ctitle(Model 1 - incidence) label addtext(Year FE, YES, Region FE, YES)	

	reghdfe onset_2 MEAN_Level L.peace_years if year >1990, absorb(_ID year) vce(cluster iso_encoded)
	outreg2 using "../../Manuscript/Regression.doc", append ctitle(Model 1 - onset) label addtext(Year FE, YES, Region FE, YES)

*********************************************************************
*Table S1 - Model 2: heteregenous effect with respect ot income level
*********************************************************************
	reghdfe conflict_incidence c.MEAN_Level##c.ln_gnic L.peace_years, absorb(_ID year) vce(cluster iso_encoded)
	outreg2 using "../../Manuscript/Regression_by_income.doc", append ctitle(incidence "income regions") label addtext(Year FE, YES, Region FE, YES)

	reghdfe onset_2 c.MEAN_Level##c.ln_gnic L.peace_years if year >1990, absorb(_ID year) vce(cluster iso_encoded)
	outreg2 using "../../Manuscript/Regression_by_income.doc", append ctitle(onset - "income regions") label addtext(Year FE, YES, Region FE, YES)

	reghdfe conflict_incidence c.MEAN_Level##c.ln_GNI_per_capita L.peace_years, absorb(_ID year) vce(cluster iso_encoded)
	outreg2 using "../../Manuscript/Regression_by_income.doc", append ctitle(incidence - "income countries") label addtext(Year FE, YES, Region FE, YES)

	reghdfe onset_2 c.MEAN_Level##c.ln_GNI_per_capita L.peace_years if year >1990, absorb(_ID year) vce(cluster iso_encoded)
	outreg2 using "../../Manuscript/Regression_by_income.doc", append ctitle(onset - "income countries") label addtext(Year FE, YES, Region FE, YES)

	
************************************************************
*Table S5: Regressions with alternative model specifications
************************************************************
	
**** Model 3: Precipitation on conflict incidence and onset without year dummies
	reghdfe conflict_incidence MEAN_Level  L.peace_years, absorb(GID_1) vce(cluster iso_encoded)
	outreg2 using "../../Manuscript/Regression_alternative_yearly.doc", replace ctitle(Model 3 - incidence) label addtext(Year FE, NO, Region FE, YES)	

	reghdfe onset_2 MEAN_Level  L.peace_years if year >1990, absorb(GID_1) vce(cluster iso_encoded)
	outreg2 using "../../Manuscript/Regression_alternative_yearly.doc", append ctitle(Model 3 - onset) label addtext(Year FE, NO, Region FE, YES)

**** Model 4: Precipitation on conflict incidence and onset with random effects
	reghdfe conflict_incidence MEAN_Level  L.peace_years, noabsorb vce(cluster iso_encoded)
	outreg2 using "../../Manuscript/Regression_alternative_yearly.doc", append ctitle(Model 4 - incidence) label addtext(Year FE, NO, Region FE, NO)	

	reghdfe onset_2 MEAN_Level  L.peace_years if year >1990, noabsorb vce(cluster iso_encoded)
	outreg2 using "../../Manuscript/Regression_alternative_yearly.doc", append ctitle(Model 4 - onset) label addtext(Year FE, NO, Region FE, NO)

**** Model 5: Precipitation on conflict incidence and onset with control vaiables
	reghdfe conflict_incidence MEAN_Level L.peace_years ln_gnic ln_pop ln_lifexp, absorb(_ID year) vce(cluster iso_encoded)
	outreg2 using "../../Manuscript/Regression_alternative_yearly.doc", append ctitle(Model 5 - incidence) keep(MEAN_Level L.peace_years  ln_gnic ln_pop ln_lifexp) label addtext(Year FE, YES, Region FE, YES)
		
	reghdfe onset_2 MEAN_Level L.peace_years ln_gnic ln_pop ln_lifexp if year >1990, absorb(_ID year) vce(cluster iso_encoded)
	outreg2 using "../../Manuscript/Regression_alternative_yearly.doc", append ctitle(Model 5 - onset) keep(MEAN_Level L.peace_years ln_gnic ln_pop ln_lifexp) label addtext(Year FE, YES, Region FE, YES)

**** Model 6: Precipitation on conflict incidence and onset with regions that experienced at least one conflict
	reghdfe conflict_incidence MEAN_Level L.peace_years if conflict_variation > 0, absorb(_ID year) vce(cluster iso_encoded)
	outreg2 using "../../Manuscript/Regression_alternative_yearly.doc", append ctitle(Model 6 - incidence) label addtext(Year FE, YES, Region FE, YES)	

	reghdfe onset_2 MEAN_Level L.peace_years if onset_variation > 0 & year >1990, absorb(_ID year) vce(cluster iso_encoded)
	outreg2 using "../../Manuscript/Regression_alternative_yearly.doc", append ctitle(Model 6 - onset) label addtext(Year FE, YES, Region FE, YES)

**** Model 7: Precipitation on conflict incidence and onset in Africa
	reghdfe conflict_incidence MEAN_Level L.peace_years if GEO=="Africa", absorb(_ID year) vce(cluster iso_encoded)
	outreg2 using "../../Manuscript/Regression_alternative_yearly.doc", append ctitle(Model 7 - incidence) label addtext(Year FE, YES, Region FE, YES)	

	reghdfe onset_2 MEAN_Level L.peace_years if GEO=="Africa" & year >1990, absorb(_ID year) vce(cluster iso_encoded)
	outreg2 using "../../Manuscript/Regression_alternative_yearly.doc", append ctitle(Model 7 - onset) label addtext(Year FE, YES, Region FE, YES)

	
*****************************************************************
*Table S8 : Regressions with alternative model specifications (2)
*****************************************************************

*** Model 8: Taking the number of conflicts instead of conflict incidence as dependent variable
	qui nbreg number_of_conflict MEAN_Level L.peace_years i.GID_1_encoded i.year, vce(cluster iso_encoded)  iterate(10)
	outreg2 using "../../Manuscript/Regression_alternative_yearly_2.doc", replace ctitle(Model 8 - Number of conflict) keep(MEAN_Level L.peace_years) e(r2_p) label addtext(Time FE, YES, Region FE, YES)	
	
**** Model 9: Logistic regression
*https://www.statalist.org/forums/forum/general-stata-discussion/general/70609-fixed-effects-logit-standard-errors
	qui logit conflict_incidence MEAN_Level L.peace_years i.GID_1_encoded i.year if conflict_variation >0, vce(cluster iso_encoded) noconstant
	outreg2 using "../../Manuscript/Regression_alternative_yearly_2.doc", append ctitle(Model 9 - Logit - incidence) keep(MEAN_Level L.peace_years) e(r2_p) label addtext(Time FE, YES, Region FE, YES)

	qui logit onset_2 MEAN_Level L.peace_years i.GID_1_encoded i.year if onset_variation >0 & year >1990, vce(cluster iso_encoded) noconstant
	outreg2 using "../../Manuscript/Regression_alternative_yearly_2.doc", append ctitle(Model 9 - Logit - onset) keep(MEAN_Level L.peace_years) e(r2_p) label addtext(Time FE, YES, Region FE, YES)

**** Model 10: Multilevel model linear regression with control variables
	xtmixed conflict_incidence MEAN_Level L.peace_years ln_gnic ln_pop ln_lifexp || iso_encoded:, mle nolog covariance(unstructured)
	outreg2 using "../../Manuscript/Regression_alternative_yearly_2.doc", append  ctitle(Model 10 - Hierarchical linear model - incidence) label addtext(Time FE, NO, Region FE, NO)
	
	xtmixed onset_2 MEAN_Level L.peace_years ln_gnic ln_pop ln_lifexp || iso_encoded: if year >1990, mle nolog covariance(unstructured)
	outreg2 using "../../Manuscript/Regression_alternative_yearly_2.doc", append ctitle(Model 10 - Hierarchical linear model - onset) label addtext(Time FE, NO, Region FE, NO)	

**** Model 11: Spatial Auto-regressive Model (SAR)
	*Creating a spatial weight matrix
	spmatrix create contiguity M if year==2000, normalize(row) replace
	
	*Performing the regressions
	spxtregress conflict_incidence MEAN_Level L_peace_year if conflict_variation > 0, fe dvarlag(M) errorlag(M) force
	outreg2 using "../../Manuscript/Regression_alternative_yearly_2.doc", append ctitle(Model 11 - SAR - incidence) keep(MEAN_Level L_peace_year) label addtext(Time FE, NO, Region FE, NO)

	* Estimating the effects for table S9
	estat impact MEAN_Level
	
	spxtregress onset_2 MEAN_Level L_peace_year if conflict_variation > 0 & year >1990, fe dvarlag(M) errorlag(M) force
	outreg2 using "../../Manuscript/Regression_alternative_yearly_2.doc", append ctitle(Model 11 - SAR - onset) keep(MEAN_Level L_peace_year) label addtext(Time FE, NO, Region FE, YES)

	* Estimating the effects for table S9
	estat impact MEAN_Level
	
**** Model 12: Block bootstrapped standard-errors
	bootstrap, reps(500) cluster(iso_encoded) idcluster(IDD) group(_ID) seed(10): xtreg conflict_incidence MEAN_Level L.peace_years i.year, fe vce(r)
	outreg2 using "../../Manuscript/Regression_alternative_yearly_2.doc", append ctitle(Model 12 - Block bootstrap - incidence)  label addtext(Time FE, YES, Region FE, YES)
	
	keep if year >1990
	bootstrap, reps(500) cluster(iso_encoded) idcluster(IDD) group(_ID) seed(10): xtreg onset_2 MEAN_Level L.peace_years i.year, fe vce(r)
	outreg2 using "../../Manuscript/Regression_alternative_yearly_2.doc", append ctitle(Model 12- Block bootstrap - onset) label addtext(Time FE, YES, Region FE, YES)

**** Reloading the data at the orginal data
	use regression_file_annually, clear
	
	
*****************************************************************
*Table S11 : Regressions with alternative definitions of rainfall
*****************************************************************
**** Model 13: Standardized rainfall variables
	reghdfe conflict_incidence z_Level L.peace_years, absorb(_ID year)  vce(cluster iso_encoded)
	outreg2 using "../../Manuscript/Regression_alternative_yearly_3.doc", replace ctitle(Model 13 - Standardized rainfall - incidence) label addtext(Time FE, YES, Region FE, YES)	

	reghdfe onset_2 z_Level L.peace_years if year >1990, absorb(_ID year) vce(cluster iso_encoded)
	outreg2 using "../../Manuscript/Regression_alternative_yearly_3.doc", append ctitle(Model 13 - Standardized rainfall - onset) label addtext(Time FE, YES, Region FE, YES)
	
**** Model 14: Standardized rainfall variables wihtout values that might be regarded as outliers
	*Visual check the distribution of standard values of rainfall and understand the reasone behind the [-3;3] range
	*hist z_Level, xline(1 2 3) normal
	*graph box z_Level, yline(3)
	reghdfe conflict_incidence z_Level L.peace_years if z_Level>=-3 & z_Level<=3, absorb(_ID year) vce(cluster iso_encoded)
	outreg2 using "../../Manuscript/Regression_alternative_yearly_3.doc", append ctitle(Model 14 - Standardized rainfall 2 - incidence) label addtext(Time FE, YES, Region FE, YES)	

	reghdfe onset_2 z_Level L.peace_years if year >1990 & z_Level>=-3 & z_Level<=3, absorb(_ID year) vce(cluster iso_encoded)
	outreg2 using "../../Manuscript/Regression_alternative_yearly_3.doc", append ctitle(Model 14 - Standardized rainfall 2  - onset) label addtext(Time FE, YES, Region FE, YES)
	
****  Model 15: Logarithm of rainfall variables
	reghdfe conflict_incidence log_Level L.peace_years, absorb(_ID year)  vce(cluster iso_encoded)
	outreg2 using "../../Manuscript/Regression_alternative_yearly_3.doc", append ctitle(Model 15 - log rainfall - incidence) label addtext(Time FE, YES, Region FE, YES)	

	reghdfe onset_2 log_Level L.peace_years if year >1990, absorb(_ID year) vce(cluster iso_encoded)
	outreg2 using "../../Manuscript/Regression_alternative_yearly_3.doc", append ctitle(Model 15 - log rainfall - onset) label addtext(Time FE, YES, Region FE, YES)
	
	
*************************************************************
*Table S13 : Regressions with alternative conflict definition
**************************************************************
	
****  Model 16: State conflicts
	reghdfe conflict_incidence_state MEAN_Level L.peace_years, absorb(_ID year)  vce(cluster iso_encoded)
	outreg2 using "../../Manuscript/Regression_alternative_yearly_4.doc", append ctitle(Model 16 - State conflicts - incidence) label addtext(Time FE, YES, Region FE, YES)	

	reghdfe onset_state_2 MEAN_Level L.peace_years if year >1990, absorb(_ID year) vce(cluster iso_encoded)
	outreg2 using "../../Manuscript/Regression_alternative_yearly_4.doc", append ctitle(Model 16 - State conflicts - onset) label addtext(Time FE, YES, Region FE, YES)
	
****  Model 17: Analyses using ACLED data - ACLED conflict data record are available from 1997
	reghdfe conflict_inc_ACLED MEAN_Level L.peace_years if year >=1997, absorb(_ID year)  vce(cluster iso_encoded)
	outreg2 using "../../Manuscript/Regression_alternative_yearly_4.doc", append ctitle(Model 17 - ACLED conflicts - incidence) label addtext(Time FE, YES, Region FE, YES)
	
	reghdfe onset_ACLED MEAN_Level  L.peace_years if year > 1998, absorb(_ID year)  vce(cluster iso_encoded)
	outreg2 using "../../Manuscript/Regression_alternative_yearly_4.doc", append ctitle(Model 17  - ACLED conflicts - onset) label addtext(Time FE, YES, Region FE, YES)
	
****  Model 18: Analyses at the country level
	collapse (mean) conflict_incidence MEAN_Level (firstnm) iso (min) onset_2 peace_years, by(iso_encoded year)
	xtset iso_encoded year

	reghdfe conflict_incidence MEAN_Level L.peace_years, absorb(iso_encoded year)
	outreg2 using "../../Manuscript/Regression_alternative_yearly_4.doc", append ctitle(Model 18 - country - incidence) label addtext(Time FE, YES, Country FE, YES)

	reghdfe onset_2 MEAN_Level  L.peace_years if year >1990, absorb(iso_encoded year)
	outreg2 using "../../Manuscript/Regression_alternative_yearly_4.doc", append ctitle(Model 18 - country - onset) label addtext(Time FE, YES, Country FE, YES)

**** Reloading the data at the regional level
	use regression_file_annually, clear
	
	
****************************************************************
* Further robustness checks with same sample for all regressions
****************************************************************

****Using the dataset for the regression analsyses
	cd"../Output"
	use regression_file_annually, clear
	xtset
	spset
	
****Restricting the data to observations with all control variables and at least one conflict during the period of study. Then, focus on data ensuring a balanced panel data
	keep if !missing(ln_gnic) & !missing(ln_pop) & !missing(ln_lifexp) & conflict_variation>0 & year >1990
	by GID_1_encoded (year), sort: replace obs_count = _N
	drop if obs_count < 29

	sort _ID year

***********************************************************
* Replications of analyses with the new sample (Table S15)
***********************************************************
**** Model 1: Main estimates
	reghdfe conflict_incidence MEAN_Level L_peace_year, absorb(_ID year) vce(cluster iso_encoded)
	outreg2 using "../../Manuscript/Regression_same_sample_year.doc", replace ctitle(Model 1 - incidence) label addtext(Year FE, YES, Region FE, YES)	

	reghdfe onset_2 MEAN_Level L_peace_year, absorb(_ID year) vce(cluster iso_encoded)
	outreg2 using "../../Manuscript/Regression_same_sample_year.doc", append ctitle(Model 1 - onset) label addtext(Year FE, YES, Region FE, YES)

**** Model 3: Fixed effects without time fixed effects
	reghdfe conflict_incidence MEAN_Level L_peace_year , absorb(_ID) vce(cluster iso_encoded)
	outreg2 using "../../Manuscript/Regression_same_sample_year.doc", append ctitle(Model 3 - incidence) label addtext(Year FE, NO, Region FE, YES)	

	reghdfe onset_2 MEAN_Level L_peace_year , absorb(_ID) vce(cluster iso_encoded)
	outreg2 using "../../Manuscript/Regression_same_sample_year.doc", append ctitle(Model 3 - onset) label addtext(Year FE, NO, Region FE, YES)
	
**** Model 4: Random effects
	reghdfe conflict_incidence MEAN_Level L_peace_year, noabsorb vce(cluster iso_encoded)
	outreg2 using "../../Manuscript/Regression_same_sample_year.doc", append ctitle(Model 4 - incidence) label addtext(Year FE, NO, Region FE, NO)	

	reghdfe onset_2 MEAN_Level L_peace_year , noabsorb vce(cluster iso_encoded)
	outreg2 using "../../Manuscript/Regression_same_sample_year.doc", append ctitle(Model 4 - onset) label addtext(Year FE, NO, Region FE, NO)

**** Model 5: Fixed effects with control variables
	reghdfe conflict_incidence MEAN_Level L_peace_year ln_gnic ln_pop ln_lifexp , noabsorb vce(cluster iso_encoded)
	outreg2 using "../../Manuscript/Regression_same_sample_year.doc", append ctitle(Model 5  - incidence) label addtext(Year FE, YES, Region FE, YES)	

	reghdfe onset_2 MEAN_Level L_peace_year ln_gnic ln_pop ln_lifexp, noabsorb vce(cluster iso_encoded)
	outreg2 using "../../Manuscript/Regression_same_sample_year.doc", append ctitle(Model 5  - onset) label addtext(Year FE, YES, Region FE, YES)

**********************************************************
* Replications of analyses with the new sample (Table S18)
**********************************************************
**** Model 8: Negative binomial regressions
	nbreg number_of_conflict MEAN_Level L_peace_year i._ID i.year, vce(cluster iso_encoded)  iterate(10)
	outreg2 using "../../Manuscript/Regression_same_sample_year_2.doc", replace ctitle(Model 8) keep(MEAN_Level L_peace_year) e(r2_p) label addtext(Time FE, YES, Region FE, YES)	

**** Model 9: Logit
	qui logit conflict_incidence MEAN_Level L_peace_year i.GID_1_encoded i.year, vce(cluster iso_encoded)
	outreg2 using "../../Manuscript/Regression_same_sample_year_2.doc", append ctitle(Model 9 - Logit - incidence)  keep(MEAN_Level L_peace_year) e(r2_p) label addtext(Year FE, YES, Region FE, YES)	

	qui logit onset_2 MEAN_Level L_peace_year i.GID_1_encoded i.year , vce(cluster iso_encoded)
	outreg2 using "../../Manuscript/Regression_same_sample_year_2.doc", append ctitle(Model 9 - Logit - onset)  keep(MEAN_Level L_peace_year) e(r2_p) label addtext(Year FE, YES, Region FE, YES)
	
**** Model 10: Hierarchichal model
	xtmixed conflict_incidence MEAN_Level L_peace_year ln_gnic ln_pop ln_lifexp || iso_encoded:, mle covariance(unstructured)
	outreg2 using "../../Manuscript/Regression_same_sample_year_2.doc", append ctitle(Model 10 - Hierarchichal model - incidence) keep(MEAN_Level L_peace_year  ln_gnic ln_pop ln_lifexp) label addtext(Year FE, NO, Region FE, NO)	

	xtmixed onset_2 MEAN_Level L_peace_year ln_gnic ln_pop ln_lifexp || iso_encoded: if onset_variation>0, mle nolog covariance(unstructured)
	outreg2 using "../../Manuscript/Regression_same_sample_year_2.doc", append ctitle(Model 10 - Hierarchichal model - onset) keep(MEAN_Level L_peace_year ln_gnic ln_pop ln_lifexp) label addtext(Year FE, NO, Region FE, NO)

**** Model 11: SAR
	* Creating the spatial weight matrix based on contiguity
	spmatrix create contiguity M if year==2000, normalize(row) replace
	
	*Performing the regressions
	spxtregress conflict_incidence MEAN_Level L_peace_year, fe dvarlag(M) errorlag(M) force
	outreg2 using "../../Manuscript/Regression_same_sample_year_2.doc", append ctitle(Model 11 - SAR - incidence) keep(MEAN_Level L_peace_year) label addtext(Time FE, NO, Region FE, YES)

	* Estimating the effects for table S9
	estat impact MEAN_Level
	
	spxtregress onset_2 MEAN_Level L_peace_year if conflict_variation > 0, fe dvarlag(M) errorlag(M) force
	outreg2 using "../../Manuscript/Regression_same_sample_year_2.doc", append ctitle(Model 11 - SAR - onset) keep(MEAN_Level L_peace_year) label addtext(Time FE, NO, Region FE, YES)

	* Estimating the effects for table S9
	estat impact MEAN_Level
	
**** Model 12: Block bootstrapped standard-errors
	bootstrap, reps(500) cluster(iso_encoded) idcluster(IDD) group(_ID) seed(10): xtreg conflict_incidence MEAN_Level L_peace_year i.year, fe vce(r)
	outreg2 using "../../Manuscript/Regression_same_sample_year_2.doc", append ctitle(Model 12 - Block bootstrap - incidence) keep(MEAN_Level L_peace_year) label addtext(Time FE, YES, Region FE, YES)
	
	bootstrap, reps(500) cluster(iso_encoded) idcluster(IDD) group(_ID) seed(10): xtreg onset_2 MEAN_Level L_peace_year i.year, fe vce(r)
	outreg2 using "../../Manuscript/Regression_same_sample_year_2.doc", append ctitle(Model 12- Block bootstrap - onset) keep(MEAN_Level L_peace_year)label addtext(Time FE, YES, Region FE, YES)
	
***********************************************************
* Replications of analyses with the new sample (Table S21)
***********************************************************
**** Model 13: Standardized rainfall variables
	reghdfe conflict_incidence z_Level L_peace_year, absorb(_ID year)  vce(cluster iso_encoded)
	outreg2 using "../../Manuscript/Regression_same_sample_year_3.doc", replace ctitle(Model 13 - Standardized rainfall - incidence) label addtext(Time FE, YES, Region FE, YES)	

	reghdfe onset_2 z_Level L_peace_year, absorb(_ID year) vce(cluster iso_encoded)
	outreg2 using "../../Manuscript/Regression_same_sample_year_3.doc", append ctitle(Model 13 - Standardized rainfall - onset) label addtext(Time FE, YES, Region FE, YES)
			
****  Model 15: Logarithm of rainfall variables
	reghdfe conflict_incidence log_Level L_peace_year, absorb(_ID year) vce(cluster iso_encoded)
	outreg2 using "../../Manuscript/Regression_same_sample_year_3.doc", append ctitle(Model 15 - log rainfall - incidence) label addtext(Time FE, YES, Region FE, YES)	

	reghdfe onset_2 log_Level L_peace_year, absorb(_ID year) vce(cluster iso_encoded)
	outreg2 using "../../Manuscript/Regression_same_sample_year_3.doc", append ctitle(Model 15 - log rainfall - onset) label addtext(Time FE, YES, Region FE, YES)

****  Model 16: State conflicts
	reghdfe conflict_incidence_state MEAN_Level L_peace_year, absorb(_ID year) vce(cluster iso_encoded)
	outreg2 using "../../Manuscript/Regression_same_sample_year_3.doc", append ctitle(Model 16 - incidence) label addtext(Time FE, YES, Region FE, YES)	

	reghdfe onset_state_2 MEAN_Level L_peace_year, absorb(_ID year) vce(cluster iso_encoded)
	outreg2 using "../../Manuscript/Regression_same_sample_year_3.doc", append ctitle(Model 16 - onset) label addtext(Time FE, YES, Region FE, YES)

********************************************************************************
****Reloading the main dataset
	cd"../Output"
	use regression_file_annually, clear
	xtset
	spset
	

*********************************************
*Table S23 : with lag values of precipitation
*********************************************

****  Model 20: Regressions with 1 lag variable
	sort _ID year
	reghdfe conflict_incidence L(0/1).MEAN_Level L.peace_years, absorb(_ID year) vce(cluster iso_encoded)
	outreg2 using "../../Manuscript/Regression_lags_year.doc", replace ctitle(Model 20 - incidence) label addtext(Year FE, YES, Region FE, YES)	

	reghdfe onset_2 L(0/1).MEAN_Level L.peace_years if year >1990, absorb(_ID year) vce(cluster iso_encoded)
	outreg2 using "../../Manuscript/Regression_lags_year.doc", append ctitle(Model 21 - onset) label addtext(Year FE, YES, Region FE, YES)

****  Model 21: Regressions with 1 lag variable as only variable
	reghdfe conflict_incidence L.MEAN_Level L.peace_years, absorb(_ID year) vce(cluster iso_encoded)
	outreg2 using "../../Manuscript/Regression_lags_year.doc", append ctitle(Model 21 - incidence) label addtext(Year FE, YES, Region FE, YES)	

	reghdfe onset_2 L.MEAN_Level  L.peace_years if year >1990, absorb(_ID year) vce(cluster iso_encoded)
	outreg2 using "../../Manuscript/Regression_lags_year.doc", append ctitle(Model 21 - onset) label addtext(Year FE, YES, Region FE, YES)

****  Model 22: Regressions with 10 lags observations
	reghdfe conflict_incidence L(0/10).MEAN_Level  L.peace_years, absorb(_ID year) vce(cluster iso_encoded)
	outreg2 using "../../Manuscript/Regression_lags_year.doc", append ctitle(Model 22 - incidence) label addtext(Year FE, YES, Region FE, YES)	

	reghdfe onset_2 L(0/10).MEAN_Level L.peace_years if year >1990, absorb(_ID year) vce(cluster iso_encoded)
	outreg2 using "../../Manuscript/Regression_lags_year.doc", append ctitle(Model 22 - onset) label addtext(Year FE, YES, Region FE, YES)

	
	
*********************************************************
* Table S24: Conflict onset defined with a 5-years cutoff
*********************************************************
	reghdfe onset_5 MEAN_Level L.peace_years if year >1993, absorb(_ID year) vce(cluster iso_encoded)
	outreg2 using "../../Manuscript/Regression_onset_5.doc", append ctitle(Model 1 - Onset 5 years) label addtext(Time FE, YES, Region FE, YES)