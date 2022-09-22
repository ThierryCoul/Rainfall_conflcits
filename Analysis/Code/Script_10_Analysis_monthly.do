****Loading the data
	cd"../Output"
	use regression_file_monthly, clear
	xtset
	spset

****Pre-estimation tests	
	*Conflict incidence - Hausman test without control variables (Table S25)
	xtreg conflict_incidence MEAN_Level L.peace_years, fe
	estimates store Fixed
	xtreg conflict_incidence MEAN_Level L.peace_years, re
	estimates store Random
	hausman Fixed Random

	*Conflict incidence - Hausman test with control variables (Table S26)
	xtreg onset_2 MEAN_Level L.peace_years if year >1990, fe
	estimates store Fixed
	xtreg onset_2 MEAN_Level L.peace_years if year >1990, re
	estimates store Random
	hausman Fixed Random

	*Conflict onset - Hausman test without control variables (Table S27)
	sort _ID time_id
	xtreg conflict_incidence MEAN_Level L.peace_years ln_gnic ln_pop ln_lifexp, fe
	estimates store Fixed
	xtreg conflict_incidence MEAN_Level L.peace_years ln_gnic ln_pop ln_lifexp, re
	estimates store Random
	hausman Fixed Random, sigmamore

	*Conflict onset - Hausman test without control variables (Table S28)
	sort _ID time_id
	xtreg onset_2 MEAN_Level L.peace_years ln_gnic ln_pop ln_lifexp if year >1990, fe
	estimates store Fixed
	xtreg onset_2 MEAN_Level L.peace_years ln_gnic ln_pop ln_lifexp if year >1990, re
	estimates store Random
	hausman Fixed Random	
	
********************************************
* Table S3 Performing the summary statistics
********************************************
	outreg2 using "../../Manuscript/Summary_stat_month.doc", replace sum(log) keep(conflict_incidence ///
		onset_2 MEAN_Level peace_years ln_gnic ln_pop ln_lifexp gnic pop lifexp)

*******************************************************
* Table 1 Model 1: Main regression at the monthly level
*******************************************************

**** Precipitation on conflict incidence and onset
	sort _ID time_id
	reghdfe conflict_incidence MEAN_Level L.peace_years, absorb(_ID time_id) vce(cluster iso_encoded)
	outreg2 using "../../Manuscript/Regression.doc", replace ctitle(Model 1 - incidence)  label addtext(Time FE, YES, Region FE, YES)
	
	reghdfe onset_2 MEAN_Level L.peace_years if year >1990, absorb(_ID time_id) vce(cluster iso_encoded)
	outreg2 using "../../Manuscript/Regression.doc", append ctitle(Model 1 - onset) label addtext(Time FE, YES, Region FE, YES)
	
*******************************
*Impact of rainfall dispersion
*******************************

**** Create a variable to contain standard deviation of precipitation by year
	gen sd_MEAN_Level = MEAN_Level

***** Collapsing by id and year
	collapse (sd) sd_MEAN_Level ///
	(max) conflict_incidence onset_2 ///
	(sum) MEAN_Level ///
	(min) L_peace_year ///
	(firstnm) iso GID_1 GID_1_encoded iso_encoded GEO ///
	, by(_ID year)

**** Model 19: Effects of intra-annual rainfall variations on conflicts
	replace L_peace_year =. if year==1989
	replace L_peace_year =round(L_peace_year)
	
	reghdfe conflict_incidence sd_MEAN_Level MEAN_Level L_peace_year, absorb(_ID year) vce(cluster iso_encoded)
	outreg2 using "../../Manuscript/Regression_dispersion.doc", replace ctitle(Model 19 - Dispersion of data - incidence) label addtext(Time FE, YES, Region FE, YES)
	reghdfe onset_2 sd_MEAN_Level MEAN_Level L_peace_year if year > 1990, absorb(_ID year) vce(cluster iso_encoded)
	outreg2 using "../../Manuscript/Regression_dispersion.doc", append ctitle(Model 19 - Dispersion of data - onset) label addtext(Time FE, YES, Region FE, YES)

**** Reloading the data at the monthly level
	use regression_file_monthly, clear
	
*******************************************************************	
*Figure 1: Regressions with leads and lags of rainfall observations
*******************************************************************
	*Precipitation on conflict incidence and onset with 6 months lead and lag variables
	sort _ID time_id
	reghdfe conflict_incidence F(6/1).MEAN_Level L(0/6).MEAN_Level L.peace_years, absorb(_ID time_id) vce(cluster iso_encoded)
	estimates store Inc
	reghdfe onset_2 F(6/1).MEAN_Level L(0/6).MEAN_Level L.peace_years, absorb(_ID time_id) vce(cluster iso_encoded)
	estimates store Ons
	coefplot Inc, bylabel( Conflict incidence (m)) ///
		   || Ons, bylabel(Conflict onset (m)) ///
		   ||, drop(_cons L.peace_years) xline(0) levels(99 95 90) ///
		   xlabel(-0.000005 "-0.0005%" 0 "0"  0.000005 "0.0005%", labsize(vsmall)) ///
		    coeflabels(L.MEAN_Level = "Rainfall (m-1)" L2.MEAN_Level = "Rainfall (m-2)" ///
			L3.MEAN_Level = "Rainfall (m-3)" L4.MEAN_Level = "Rainfall (m-4)" ///
			L5.MEAN_Level = "Rainfall (m-5)" L6.MEAN_Level = "Rainfall (m-6)" ///
			F.MEAN_Level = "Rainfall (m+1)" F2.MEAN_Level = "Rainfall (m+2)" ///
			F3.MEAN_Level = "Rainfall (m+3)" F4.MEAN_Level = "Rainfall (m+4)" ///
			F5.MEAN_Level = "Rainfall (m+5)" F6.MEAN_Level = "Rainfall (m+6)" ///
			MEAN_Level = "Rainfall (m)", labsize(small))
			
	graph export "../../Manuscript/Graph_regession_leads_lags.png", width(5000) replace

	
*************************************************************************
*Data for Figure 2: Impact of rainfall on conflict incidence per regions*
*************************************************************************

****Loading the data
	use regression_file_monthly, clear

	gen xb = .
	gen z = .
	gen p_value = .
	egen id = group(GID_1_encoded) 
	sum id
	sort _ID time_id
	loc rmax = r(max)
	forvalues n = 1/`rmax' {
		di `n'
		qui reg conflict_incidence MEAN_Level  L.peace_years i.year i.month if id == `n'
		qui replace xb =  _b[MEAN_Level] if id == `n'
		qui replace z = xb / _se[MEAN_Level] if id == `n'
		qui replace p_value = 2*normal(-abs(z)) if id == `n'
		}

	keep if xb < .
	keep xb z p_value iso GID_1
	duplicates drop
	export excel "Conflict_avoided.xlsx", replace firstrow(variables)

**** Reloading the data at the regional level
	use regression_file_monthly, clear	

	

**********************************************************************
*Table S1 - Model 2: heteregenous effects with respect to income level
**********************************************************************

	*Regressions with interaction of regional income 
	reghdfe conflict_incidence c.MEAN_Level##c.ln_gnic L.peace_years, absorb(_ID time_id)  vce(cluster iso_encoded)
	outreg2 using "../../Manuscript/Regression_by_income.doc", replace ctitle(incidence - "income regions")  label addtext(Time FE, YES,Region FE, YES)

	reghdfe onset_2 c.MEAN_Level##c.ln_gnic L.peace_years if year >1990, absorb(_ID time_id) vce(cluster iso_encoded)
	outreg2 using "../../Manuscript/Regression_by_income.doc", append ctitle(onset - "income regions")  label addtext(Time FE, YES,Region FE, YES)

	*Regressions with interaction of national income 
	reghdfe conflict_incidence c.MEAN_Level##c.ln_GNI_per_capita L.peace_years, absorb(_ID time_id)  vce(cluster iso_encoded)
	outreg2 using "../../Manuscript/Regression_by_income.doc", append ctitle(incidence - "income countries")  label addtext(Time FE, YES,Region FE, YES)

	reghdfe onset_2 c.MEAN_Level##c.ln_GNI_per_capita L.peace_years if year >1990, absorb(_ID time_id) vce(cluster iso_encoded)
	outreg2 using "../../Manuscript/Regression_by_income.doc", append ctitle(onset - "income countries") label addtext(Time FE, YES,Region FE, YES)


************************************************************
*Table S4: Regressions with alternative model specifications
************************************************************
	
**** Model 3: Precipitation on conflict incidence and onset without time dummies
	reghdfe conflict_incidence MEAN_Level L.peace_years, absorb(_ID) vce(cluster iso_encoded)
	outreg2 using "../../Manuscript/Regression_alternative_monthly.doc", replace ctitle(Model 3 - incidence)  label addtext(Time FE, NO, Region FE, YES)	

	reghdfe onset_2 MEAN_Level L.peace_years if year >1990, absorb(_ID) vce(cluster iso_encoded)
	outreg2 using "../../Manuscript/Regression_alternative_monthly.doc", append ctitle(Model 3 - onset)  label addtext(Time FE, NO, Region FE, YES)

**** Model 4: Precipitation on conflict incidence and onset with random effects
	reghdfe conflict_incidence MEAN_Level L.peace_years, noabsorb vce(cluster iso_encoded)
	outreg2 using "../../Manuscript/Regression_alternative_monthly.doc", append ctitle(Model 4 - incidence)  label addtext(Time FE, NO, Region FE, NO)	

	reghdfe onset_2 MEAN_Level L.peace_years if year >1990, noabsorb vce(cluster iso_encoded)
	outreg2 using "../../Manuscript/Regression_alternative_monthly.doc", append ctitle(Model 4 - onset)  label addtext(Time FE, NO, Region FE, NO)

**** Model 5: Precipitation on conflict incidence and onset with control variables
	reghdfe conflict_incidence MEAN_Level L.peace_years ln_gnic ln_pop ln_lifexp, absorb(_ID time_id)  vce(cluster iso_encoded)
	outreg2 using "../../Manuscript/Regression_alternative_monthly.doc", append ctitle(Model 5 - incidence) keep(MEAN_Level L.peace_years ln_gnic ln_pop ln_lifexp)  label addtext(Time FE, YES,Region FE, YES)
		
	reghdfe onset_2 MEAN_Level L.peace_years ln_gnic ln_pop ln_lifexp if year >1990, absorb(_ID time_id) vce(cluster iso_encoded)
	outreg2 using "../../Manuscript/Regression_alternative_monthly.doc", append ctitle(Model 5 - onset) label addtext(Time FE, YES,Region FE, YES)

**** Model 6: Precipitation on conflict incidence and onset_2 with regions that experienced at least one conflict
	reghdfe conflict_incidence MEAN_Level  L.peace_years if conflict_variation > 0, absorb(_ID time_id) vce(cluster iso_encoded)
	outreg2 using "../../Manuscript/Regression_alternative_monthly.doc", append ctitle(Model 6 - incidence) label addtext(Time FE, YES,Region FE, YES)
	
	reghdfe onset_2 MEAN_Level L.peace_years if year >1990 & onset_2_variation > 0, absorb(_ID time_id)  vce(cluster iso_encoded)
	outreg2 using "../../Manuscript/Regression_alternative_monthly.doc", append ctitle(Model 6 - onset) label addtext(Time FE, YES,Region FE, YES)

**** Model 7: Precipitation on conflict incidence and onset in Africa
	reghdfe conflict_incidence MEAN_Level L.peace_years if GEO=="Africa", absorb(_ID time_id)  vce(cluster iso_encoded)
	outreg2 using "../../Manuscript/Regression_alternative_monthly.doc", append ctitle(Model 7 - incidence) label addtext(Time FE, YES,Region FE, YES)
	
	reghdfe onset_2 MEAN_Level L.peace_years if year >1990 & GEO=="Africa", absorb(_ID time_id)  vce(cluster iso_encoded)
	outreg2 using "../../Manuscript/Regression_alternative_monthly.doc", append ctitle(Model 7 - onset) label addtext(Time FE, YES,Region FE, YES)

	
************************************************************************************
*Table S6 : Regressions with alternative regression techniques at the monthly level
************************************************************************************

**** Model 8: Taking the number of conflicts instead of conflict incidence as dependent variable
	qui nbreg number_of_conflict MEAN_Level L.peace_years i.GID_1_encoded i.time_id, vce(cluster iso_encoded)  iterate(10)
	outreg2 using "../../Manuscript/Regression_alternative_monthly_2.doc", replace ctitle(Model 8) keep(MEAN_Level L.peace_years) addstat(Pseudo R-squared, e(r2_p)) label addtext(Time FE, YES, Region FE, YES)	


**** Model 9: Logistic regression
*https://www.statalist.org/forums/forum/general-stata-discussion/general/70609-fixed-effects-logit-standard-errors
	qui logit conflict_incidence MEAN_Level L.peace_years i.GID_1_encoded i.year i.month if conflict_variation >0, vce(cluster iso_encoded)
	outreg2 using "../../Manuscript/Regression_alternative_monthly_2.doc", append ctitle(Model 9 - Logit) keep(MEAN_Level L.peace_years) addstat(Pseudo R-squared, e(r2_p)) label  addtext(Time FE, YES, Region FE, YES)

	qui logit onset_2 MEAN_Level L.peace_years i.GID_1_encoded i.year i.month if onset_2_variation >0 & year >1990, vce(cluster iso_encoded)
	outreg2 using "../../Manuscript/Regression_alternative_monthly_2.doc", append ctitle(Model 9 - Logit) keep(MEAN_Level L.peace_years)  addstat(Pseudo R-squared, e(r2_p)) label  addtext(Time FE, YES, Region FE, YES)


**** Model 10: Multilevel model linear regression with control variables
	xtmixed conflict_incidence MEAN_Level L.peace_years ln_gnic ln_pop ln_lifexp || iso_encoded:, mle nolog covariance(unstructured)
	outreg2 using "../../Manuscript/Regression_alternative_monthly_2.doc", append  ctitle(Model 10 - Hierarchical linear　- incidence)  label addtext(Time FE, NO, Region FE, NO)
	
	xtmixed onset_2 MEAN_Level L.peace_years ln_gnic ln_pop ln_lifexp || iso_encoded: if year > 1990, mle nolog covariance(unstructured)
	outreg2 using "../../Manuscript/Regression_alternative_monthly_2.doc", append ctitle(Model 10 - Hierarchical linear - onset)  label addtext(Time FE, NO, Region FE, NO)	
	
	
**** Model 11: Spatial Auto-regressive Model (SAR)
	*Creating a spatial weight matrix
	spmatrix create contiguity M if time_id== 5, normalize(row) replace
	
	*Performing the regressions
	spxtregress conflict_incidence MEAN_Level L_peace_year if conflict_variation > 0, fe dvarlag(M) errorlag(M) force
	outreg2 using "../../Manuscript/Regression_alternative_monthly_2.doc", append ctitle(Model 11 - SAR - incidence) keep(MEAN_Level L.peace_years ) addstat(Pseudo R-squared, e(r2_p)) label addtext(Time FE, NO, Region FE, YES)
	
	* Estimating the effects for table S7
	estat impact MEAN_Level
	
	spxtregress onset_2 MEAN_Level L_peace_year  if year >1990 & onset_2_variation> 0, fe dvarlag(M) errorlag(M) force
	outreg2 using "../../Manuscript/Regression_alternative_monthly_2.doc", append ctitle(Model 11 - SAR - onset) keep(MEAN_Level L.peace_years) addstat(Pseudo R-squared, e(r2_p)) label addtext(Time FE, NO, Region FE, YES)

	* Estimating the effects for table S7
	estat impact MEAN_Level
	
**** Model 12: Block bootstrapped standard-errors
	bootstrap, reps(500) cluster(iso_encoded) idcluster(IDD) group(_ID) seed(10): xtreg conflict_incidence MEAN_Level L.peace_years i.time_id, fe vce(r)
	outreg2 using "../../Manuscript/Regression_alternative_monthly_2.doc", append ctitle(Model 12 - Block bootstrap - incidence)  label addtext(Time FE, YES, Region FE, YES)
	
	keep if year >1990
	bootstrap, reps(500) cluster(iso_encoded) idcluster(IDD) group(_ID) seed(10): xtreg onset_2 MEAN_Level L.peace_years i.time_id if year >1990, fe vce(r)
	outreg2 using "../../Manuscript/Regression_alternative_monthly_2.doc", append ctitle(Model 12 - Block bootstrap - onset) label addtext(Time FE, YES, Region FE, YES)
	
**** Reloading the data at the original data
	use regression_file_monthly, clear
	
*******************************************************************************************************
*Table S10 : Regressions with alternative definitions of the independent variable at the monthly level
*******************************************************************************************************

**** Model 13: Standardized rainfall variables
	reghdfe conflict_incidence z_Level L.peace_years, absorb(_ID time_id)  vce(cluster iso_encoded)
	outreg2 using "../../Manuscript/Regression_alternative_monthly_3.doc", replace ctitle(Model 13 - Standardized rainfall - incidence) label addtext(Time FE, YES, Region FE, YES)	

	reghdfe onset_2 z_Level L.peace_years if year >1990, absorb(_ID time_id) vce(cluster iso_encoded)
	outreg2 using "../../Manuscript/Regression_alternative_monthly_3.doc", append ctitle(Model 13 - Standardized rainfall - onset) label addtext(Time FE, YES, Region FE, YES)
	
**** Model 14: Standardized rainfall variables wihtout values that might be regarded as outliers
	*Visual check the distribution of standard values of rainfall and understand the reasone behind the [-3;3] range
	*hist z_Level, xline(1 2 3) normal
	*graph box z_Level, yline(3)
	reghdfe conflict_incidence z_Level L.peace_years if z_Level>=-3 & z_Level<=3, absorb(_ID time_id) vce(cluster iso_encoded)
	outreg2 using "../../Manuscript/Regression_alternative_monthly_3.doc", append ctitle(Model 14 - Standardized rainfall 2 - incidence) label addtext(Time FE, YES, Region FE, YES)	

	reghdfe onset_2 z_Level L.peace_years if year >1990 & z_Level>=-3 & z_Level<=3, absorb(_ID time_id) vce(cluster iso_encoded)
	outreg2 using "../../Manuscript/Regression_alternative_monthly_3.doc", append ctitle(Model 14 - Standardized rainfall 2 - onset) label addtext(Time FE, YES, Region FE, YES)
	
****  Model 15: Logarithm of rainfall variables
	reghdfe conflict_incidence log_Level L.peace_years, absorb(_ID time_id)  vce(cluster iso_encoded)
	outreg2 using "../../Manuscript/Regression_alternative_monthly_3.doc", append ctitle(Model 15 - log rainfall - incidence) label addtext(Time FE, YES, Region FE, YES)	

	reghdfe onset_2 log_Level L.peace_years if year >1990, absorb(_ID time_id) vce(cluster iso_encoded)
	outreg2 using "../../Manuscript/Regression_alternative_monthly_3.doc", append ctitle(Model 15 - log rainfall - onset) label addtext(Time FE, YES, Region FE, YES)
	
	
	
***************************************************************************************
*Table S12 : Regressions with alternative data/conflict definition at the monthly level
***************************************************************************************
	
****  Model 16: State conflicts
	reghdfe conflict_incidence_state MEAN_Level L.peace_years, absorb(_ID time_id)  vce(cluster iso_encoded)
	outreg2 using "../../Manuscript/Regression_alternative_monthly_4.doc", append ctitle(Model 16 - State conflicts - incidence) label addtext(Time FE, YES, Region FE, YES)
	
	reghdfe onset_state_2 MEAN_Level L.peace_years if year > 1990, absorb(_ID time_id)  vce(cluster iso_encoded)
	outreg2 using "../../Manuscript/Regression_alternative_monthly_4.doc", append ctitle(Model 16 - State conflicts - onset) label addtext(Time FE, YES, Region FE, YES)
	
****  Model 17: Analysis using ACLED data - ACLED conflict data record are available from 1997
	reghdfe conflict_inc_ACLED MEAN_Level L.peace_years if year >=1997 & year <= 2018, absorb(_ID time_id)  vce(cluster iso_encoded)
	outreg2 using "../../Manuscript/Regression_alternative_monthly_4.doc", append ctitle(Model 17 - ACLED conflicts - incidence) label addtext(Time FE, YES, Region FE, YES)
	
	reghdfe onset_ACLED MEAN_Level L.peace_years if year > 1998 & year <= 2018, absorb(_ID time_id)  vce(cluster iso_encoded)
	outreg2 using "../../Manuscript/Regression_alternative_monthly_4.doc", append ctitle(Model 17 - ACLED conflicts - onset) label addtext(Time FE, YES, Region FE, YES)

****  Model 18: Analysis at the country level
	collapse conflict_incidence MEAN_Level onset_2 (firstnm) iso (min) peace_years, by(iso_encoded year month time_id)
	xtset iso_encoded time_id

	reghdfe conflict_incidence MEAN_Level L.peace_years, absorb(iso_encoded time_id) vce(r)
	outreg2 using "../../Manuscript/Regression_alternative_monthly_4.doc", append ctitle(Model 18 - country - incidence) label addtext(Time FE, YES, Country FE, YES)

	reghdfe onset_2 MEAN_Level L.peace_years if year > 1990, absorb(iso_encoded time_id) vce(r)
	outreg2 using "../../Manuscript/Regression_alternative_monthly_4.doc", append ctitle(Model 18 - country - onset) label addtext(Time FE, YES, Country FE, YES)

**** Reloading the data at the regional level
	use regression_file_monthly, clear


	
****************************************************************
* Further robustness checks with same sample for all regressions
****************************************************************

****Using the dataset for the regression analsyses
	cd"../Output"
	use regression_file_monthly, clear
	xtset
	spset
	
****Restricting the data to observations with all control variables and at least one conflict during the period of study. Then, focus on data ensuring a balanced panel data
	keep if !missing(ln_gnic) & !missing(ln_pop) & !missing(ln_lifexp) & conflict_variation>0 & year >1990
	by _ID (time_id), sort: replace obs_count = _N
	drop if obs_count < 348

	sort _ID time_id
	
***********************************************************
* Replications of analyses with the new sample (Table S14)
***********************************************************
**** Model 1: Fixed effects
	reghdfe conflict_incidence MEAN_Level L_peace_year , absorb(_ID time_id) vce(cluster iso_encoded)
	outreg2 using "../../Manuscript/Regression_same_sample_month.doc", replace ctitle(Model 1 - incidence) label addtext(Time FE, YES, Region FE, YES)	

	reghdfe onset_2 MEAN_Level L_peace_year, absorb(_ID time_id) vce(cluster iso_encoded)
	outreg2 using "../../Manuscript/Regression_same_sample_month.doc", append ctitle(Model 1 - onset) label addtext(Time FE, YES, Region FE, YES)

**** Model 3: Fixed effects without time fixed effects
	reghdfe conflict_incidence MEAN_Level L_peace_year , absorb(_ID) vce(cluster iso_encoded)
	outreg2 using "../../Manuscript/Regression_same_sample_month.doc", append ctitle(Model 3 - incidence) label addtext(Time FE, YES, Region FE, YES)	

	reghdfe onset_2 MEAN_Level L_peace_year, absorb(_ID) vce(cluster iso_encoded)
	outreg2 using "../../Manuscript/Regression_same_sample_month.doc", append ctitle(Model 3 - onset) label addtext(Time FE, YES, Region FE, YES)
	
**** Model 4: Random effects
	reghdfe conflict_incidence MEAN_Level L_peace_year, noabsorb vce(cluster iso_encoded)
	outreg2 using "../../Manuscript/Regression_same_sample_month.doc", append ctitle(Model 4 - incidence) label addtext(Time FE, YES, Region FE, YES)	

	reghdfe onset_2 MEAN_Level L_peace_year , noabsorb vce(cluster iso_encoded)
	outreg2 using "../../Manuscript/Regression_same_sample_month.doc", append ctitle(Model 4 - onset) label addtext(Time FE, YES, Region FE, YES)

**** Fixed effects with control variables
	reghdfe conflict_incidence MEAN_Level L_peace_year ln_gnic ln_pop ln_lifexp , noabsorb vce(cluster iso_encoded)
	outreg2 using "../../Manuscript/Regression_same_sample_month.doc", append ctitle(Model 5 - incidence) label addtext(Time FE, YES, Region FE, YES)

	reghdfe onset_2 MEAN_Level L_peace_year ln_gnic ln_pop ln_lifexp , noabsorb vce(cluster iso_encoded)
	outreg2 using "../../Manuscript/Regression_same_sample_month.doc", append ctitle(Model 5 - onset) label addtext(Time FE, YES, Region FE, YES)

	
***********************************************************
* Replications of analyses with the new sample (Table S16)
***********************************************************
**** Model 8: Negative binomial regressions
	nbreg number_of_conflict MEAN_Level L_peace_year i._ID i.time_id, vce(cluster iso_encoded)  iterate(10)
	outreg2 using "../../Manuscript/Regression_same_sample_month_2.doc", replace ctitle(Model 8 - Negative binomial) keep(MEAN_Level L_peace_year ) e(r2_p) label addtext(Time FE, YES, Region FE, YES)	

**** Model 9: Logit
	qui logit conflict_incidence MEAN_Level L_peace_year i._ID i.time_id, vce(cluster iso_encoded)
	outreg2 using "../../Manuscript/Regression_same_sample_month_2.doc", append ctitle(Model 9 - Logit - incidence)  keep(MEAN_Level L_peace_year) e(r2_p) label addtext(Time FE, YES, Region FE, YES)	

	qui logit onset_2 MEAN_Level L_peace_year i._ID i.time_id , vce(cluster iso_encoded)
	outreg2 using "../../Manuscript/Regression_same_sample_month_2.doc", append ctitle(Model 9 - Logit - onset)  keep(MEAN_Level L_peace_year) e(r2_p) label addtext(Time FE, YES, Region FE, YES)
	
**** Model 10: Hierarchichal model
	xtmixed conflict_incidence MEAN_Level L_peace_year ln_gnic ln_pop ln_lifexp || iso_encoded:, mle covariance(unstructured)
	outreg2 using "../../Manuscript/Regression_same_sample_month_2.doc", append ctitle(Model 10 - Hierarchichal model - incidence) keep(MEAN_Level L_peace_year  ln_gnic ln_pop ln_lifexp) label addtext(Time FE, NO, Region FE, NO)	

	xtmixed onset_2 MEAN_Level L_peace_year ln_gnic ln_pop ln_lifexp || iso_encoded:, mle nolog covariance(unstructured)
	outreg2 using "../../Manuscript/Regression_same_sample_month_2.doc", append ctitle(Model 10 - Hierarchichal model - onset) keep(MEAN_Level L_peace_year  ln_gnic ln_pop ln_lifexp) label addtext(Time FE, NO, Region FE, NO)

**** Model 11: SAR
	spmatrix create contiguity M if time_id==100, normalize(row) replace
	
	*Performing the regressions
	spxtregress conflict_incidence MEAN_Level L_peace_year, fe dvarlag(M) errorlag(M) force
	outreg2 using "../../Manuscript/Regression_same_sample_month_2.doc", append ctitle(Model 11 - SAR - incidence) keep(MEAN_Level L_peace_year) label addtext(Time FE, NO, Region FE, YES)

	* Estimating the effects for table S17
	estat impact MEAN_Level
	
	spxtregress onset_2 MEAN_Level L_peace_year, fe dvarlag(M) errorlag(M) force
	outreg2 using "../../Manuscript/Regression_same_sample_month_2.doc", append ctitle(Model 11 - SAR - onset) keep(MEAN_Level L_peace_year) label addtext(Time FE, NO, Region FE, YES)

	* Estimating the effects for table S17
	estat impact MEAN_Level
	
**** Model 12: Block bootstrap 
	bootstrap, reps(500) cluster(iso_encoded) idcluster(IDD) group(_ID) seed(10): xtreg conflict_incidence MEAN_Level L_peace_year i.time_id, fe vce(r)
	outreg2 using "../../Manuscript/Regression_same_sample_month_2.doc", append ctitle(Model 12 - Block bootstrap - incidence) keep(MEAN_Level L_peace_year) label addtext(Time FE, YES, Region FE, YES)
	
	bootstrap, reps(500) cluster(iso_encoded) idcluster(IDD) group(_ID) seed(10): xtreg onset_2 MEAN_Level L_peace_year i.time_id, fe vce(r)
	outreg2 using "../../Manuscript/Regression_same_sample_month_2.doc", append ctitle(Model 12- Block bootstrap - onset) keep(MEAN_Level L_peace_year)label addtext(Time FE, YES, Region FE, YES)

***********************************************************
* Replications of analyses with the new sample (Table S20)
***********************************************************	

**** Model 13: Standardized rainfall variables
	reghdfe conflict_incidence z_Level L_peace_year, absorb(_ID time_id)  vce(cluster iso_encoded)
	outreg2 using "../../Manuscript/Regression_same_sample_month_3.doc", replace ctitle(Model 13 - Standardized rainfall - incidence) label addtext(Time FE, YES, Region FE, YES)	

	reghdfe onset_2 z_Level L_peace_year, absorb(_ID time_id) vce(cluster iso_encoded)
	outreg2 using "../../Manuscript/Regression_same_sample_month_3.doc", append ctitle(Model 13 - Standardized rainfall - onset) label addtext(Time FE, YES, Region FE, YES)
		
****  Model 15: Logarithm of rainfall variables
	reghdfe conflict_incidence log_Level L_peace_year, absorb(_ID time_id) vce(cluster iso_encoded)
	outreg2 using "../../Manuscript/Regression_same_sample_month_3.doc", append ctitle(Model 15 - log rainfall - incidence) label addtext(Time FE, YES, Region FE, YES)	

	reghdfe onset_2 log_Level L_peace_year, absorb(_ID time_id) vce(cluster iso_encoded)
	outreg2 using "../../Manuscript/Regression_same_sample_month_3.doc", append ctitle(Model 15 - log rainfall - onset) label addtext(Time FE, YES, Region FE, YES)

****  Model 16: State conflicts
	reghdfe conflict_incidence_state MEAN_Level L_peace_year, absorb(_ID time_id) vce(cluster iso_encoded)
	outreg2 using "../../Manuscript/Regression_same_sample_month_3.doc", append ctitle(Model 16 - State conflicts - incidence) label addtext(Time FE, YES, Region FE, YES)	

	reghdfe onset_state_2 MEAN_Level L_peace_year, absorb(_ID time_id) vce(cluster iso_encoded)
	outreg2 using "../../Manuscript/Regression_same_sample_month_3.doc", append ctitle(Model 16 - State conflicts - onset) label addtext(Time FE, YES, Region FE, YES)


*********************************************
*Table S22 : with lag values of precipitation
*********************************************
	sort _ID time_id
	reghdfe conflict_incidence MEAN_Level L.peace_years, absorb(GID_1_encoded time_id) vce(cluster iso_encoded)
	outreg2 using "../../Manuscript/Regression_lags_month.doc", replace ctitle(Model 20 - incidence) label addtext(Year FE, YES, Region FE, YES)	

	reghdfe onset_2 MEAN_Level L.peace_years if year >1990, absorb(_ID time_id)  vce(cluster iso_encoded)
	outreg2 using "../../Manuscript/Regression_lags_month.doc", append ctitle(Model 20 - onset) label addtext(Year FE, YES, Region FE, YES)

	reghdfe conflict_incidence L.MEAN_Level L.peace_years, absorb(GID_1_encoded time_id) vce(cluster iso_encoded)
	outreg2 using "../../Manuscript/Regression_lags_month.doc", append ctitle(Model 21 - incidence) label addtext(Year FE, YES, Region FE, YES)	

	reghdfe onset_2 L.MEAN_Level L.peace_years if year >1990, absorb(GID_1_encoded time_id) vce(cluster iso_encoded)
	outreg2 using "../../Manuscript/Regression_lags_month.doc", append ctitle(Model 21 - onset) label addtext(Year FE, YES, Region FE, YES)	

	reghdfe conflict_incidence L(0/11).MEAN_Level L.peace_years, absorb(GID_1_encoded time_id) vce(cluster iso_encoded)
	outreg2 using "../../Manuscript/Regression_lags_month.doc", append ctitle(Model 22 - incidence) label addtext(Year FE, YES, Region FE, YES)	

	reghdfe onset_2 L(0/11).MEAN_Level L.peace_years if year >1990, absorb(GID_1_encoded time_id) vce(cluster iso_encoded)
	outreg2 using "../../Manuscript/Regression_lags_month.doc", append ctitle(Model 22 - onset) label addtext(Year FE, YES, Region FE, YES)

	
*********************************************************
* Table S24: Conflict onset defined with a 5-year cutoff
*********************************************************
	reghdfe onset_5 MEAN_Level L.peace_years if year >1993, absorb(_ID time_id) vce(cluster iso_encoded)
	outreg2 using "../../Manuscript/Regression_onset_5.doc", replace ctitle(Model 1 - Onset 5 years) label addtext(Time FE, YES, Region FE, YES)