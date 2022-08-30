****Loading the data
	cd"../Output"
	use regression_file_monthly, clear
	xtset
	spset

****Pre-estimation tests	
	*Hausman test without contol variables
	xtreg conflict_incidence MEAN_Level L.peace_years, fe
	estimates store Fixed
	xtreg conflict_incidence MEAN_Level L.peace_years, re
	estimates store Random
	hausman Fixed Random

	*Hausman test without contol variables
	xtreg onset_2 MEAN_Level L.peace_years, fe
	estimates store Fixed
	xtreg onset_2 MEAN_Level L.peace_years, re
	estimates store Random
	hausman Fixed Random

	*Hausman test with contol variables
	sort _ID time_id
	xtreg conflict_incidence MEAN_Level L.peace_years ln_gnic ln_pop ln_lifexp, fe
	estimates store Fixed
	xtreg conflict_incidence MEAN_Level L.peace_years ln_gnic ln_pop ln_lifexp, re
	estimates store Random
	hausman Fixed Random, sigmamore

	*Hausman test with contol variables
	sort _ID time_id
	xtreg onset_2 MEAN_Level L.peace_years ln_gnic ln_pop ln_lifexp, fe
	estimates store Fixed
	xtreg onset_2 MEAN_Level L.peace_years ln_gnic ln_pop ln_lifexp, re
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
	reghdfe conflict_incidence MEAN_Level L.peace_years, absorb(_ID i._ID#c.time_id)  vce(cluster iso_encoded)
	outreg2 using "../../Manuscript/Regression.doc", replace ctitle(Model 1)  label addtext(Time FE, YES, Region FE, YES)
	
	reghdfe onset_2 MEAN_Level L.peace_years, absorb(GID_1 time_id)  vce(cluster iso_encoded)
	outreg2 using "../../Manuscript/Regression5.doc", append ctitle(Model 1)  label addtext(Time FE, YES, Region FE, YES)
	
*********************************************************************
*Table 2 - Model 2: heteregenous effect with respect ot income level
*********************************************************************

	*Regressions with interaction of regional income 
	reghdfe conflict_incidence c.MEAN_Level##c.ln_gnic L.peace_years, absorb(GID_1 time_id)  vce(cluster iso_encoded)
	outreg2 using "../../Manuscript/Regression_by_income.doc", replace ctitle(Conflict - "income regions")  label addtext(Time FE, YES,Region FE, YES)

	reghdfe onset_2 c.MEAN_Level##c.ln_gnic L.peace_years, absorb(GID_1 time_id) vce(cluster iso_encoded)
	outreg2 using "../../Manuscript/Regression_by_income.doc", append ctitle(onset - "income regions")  label addtext(Time FE, YES,Region FE, YES)

	*Regressions with interaction of national income 
	reghdfe conflict_incidence c.MEAN_Level##c.ln_GNI_per_capita L.peace_years, absorb(GID_1 time_id)  vce(cluster iso_encoded)
	outreg2 using "../../Manuscript/Regression_by_income.doc", append ctitle(Conflict - "income countries")  label addtext(Time FE, YES,Region FE, YES)

	reghdfe onset_2 c.MEAN_Level##c.ln_GNI_per_capita L.peace_years, absorb(GID_1 time_id) vce(cluster iso_encoded)
	outreg2 using "../../Manuscript/Regression_by_income.doc", append ctitle(onset - "income countries") label addtext(Time FE, YES,Region FE, YES)


************************************************************
*Table S4: Regressions with alternative model specifications
************************************************************
	
**** Model 3: Precipitation on conflict incidence and onset without time dummies
	reghdfe conflict_incidence MEAN_Level L.peace_years, absorb(GID_1) vce(cluster iso_encoded)
	outreg2 using "../../Manuscript/Regression_alternative_monthly.doc", replace ctitle(Model 3)  label addtext(Time FE, NO, Region FE, YES)	

	reghdfe onset_2 MEAN_Level L.peace_years, absorb(GID_1) vce(cluster iso_encoded)
	outreg2 using "../../Manuscript/Regression_alternative_monthly.doc", append ctitle(Model 3)  label addtext(Time FE, NO, Region FE, YES)

**** Model 4: Precipitation on conflict incidence and onset with random effects
	reghdfe conflict_incidence MEAN_Level L.peace_years, noabsorb vce(cluster iso_encoded)
	outreg2 using "../../Manuscript/Regression_alternative_monthly.doc", append ctitle(Model 4)  label addtext(Time FE, NO, Region FE, NO)	

	reghdfe onset_2 MEAN_Level L.peace_years, noabsorb vce(cluster iso_encoded)
	outreg2 using "../../Manuscript/Regression_alternative_monthly.doc", append ctitle(Model 4)  label addtext(Time FE, NO, Region FE, NO)

**** Model 5: Precipitation on conflict incidence and onset with control vaiables
	reghdfe conflict_incidence MEAN_Level L.peace_years ln_gnic ln_pop ln_lifexp, absorb(GID_1_encoded time_id)  vce(cluster iso_encoded)
	outreg2 using "../../Manuscript/Regression_alternative_monthly.doc", append ctitle(Model 5) keep(MEAN_Level L.peace_years ln_gnic ln_pop ln_lifexp)  label addtext(Time FE, YES,Region FE, YES)
		
	reghdfe onset_2 MEAN_Level L.peace_years ln_gnic ln_pop ln_lifexp, absorb(GID_1_encoded time_id) vce(cluster iso_encoded)
	outreg2 using "../../Manuscript/Regression_alternative_monthly.doc", append ctitle(Model 5) label addtext(Time FE, YES,Region FE, YES)

**** Model 6: Precipitation on conflict incidence and onset_2 with regions that experienced at least one conflict
	reghdfe conflict_incidence MEAN_Level  L.peace_years if conflict_variation > 0, absorb(GID_1 time_id) vce(cluster iso_encoded)
	outreg2 using "../../Manuscript/Regression_alternative_monthly.doc", append ctitle(Model 6) label addtext(Time FE, YES,Region FE, YES)
	
	reghdfe onset_2 MEAN_Level L.peace_years if onset_2_variation > 0, absorb(GID_1 time_id)  vce(cluster iso_encoded)
	outreg2 using "../../Manuscript/Regression_alternative_monthly.doc", append ctitle(Model 6) label addtext(Time FE, YES,Region FE, YES)

**** Model 7: Precipitation on conflict incidence and onset in Africa
	reghdfe conflict_incidence MEAN_Level L.peace_years if GEO=="Africa", absorb(GID_1 time_id)  vce(cluster iso_encoded)
	outreg2 using "../../Manuscript/Regression_alternative_monthly.doc", append ctitle(Model 7) label addtext(Time FE, YES,Region FE, YES)
	
	reghdfe onset_2 MEAN_Level L.peace_years if GEO=="Africa", absorb(GID_1 time_id)  vce(cluster iso_encoded)
	outreg2 using "../../Manuscript/Regression_alternative_monthly.doc", append ctitle(Model 7) label addtext(Time FE, YES,Region FE, YES)

	
*****************************************************************
*Table S6 : Regressions with alternative model specifications (2)
*****************************************************************

**** Model 8: Taking the number of conflicts instead of conflict incidence as dependent variable
	qui nbreg number_of_conflict MEAN_Level L.peace_years i.GID_1_encoded i.time_id, vce(cluster iso_encoded)  iterate(10)
	outreg2 using "../../Manuscript/Regression_alternative_monthly_2.doc", replace ctitle(Model 8) keep(MEAN_Level L.peace_years) addstat(Pseudo R-squared, e(r2_p), Degrees of Freedom, e(df_m)) label addtext(Time FE, YES, Region FE, YES)	
	
**** Model 9: Logistic regression
*https://www.statalist.org/forums/forum/general-stata-discussion/general/70609-fixed-effects-logit-standard-errors
	qui logit conflict_incidence MEAN_Level L.peace_years i.GID_1_encoded i.year i.month if conflict_variation >0, vce(cluster iso_encoded)
	outreg2 using "../../Manuscript/Regression_alternative_monthly_2.doc", append ctitle(Model 9 - Logit) keep(MEAN_Level L.peace_years) addstat(Pseudo R-squared, e(r2_p), Degrees of Freedom, e(df_m)) label  addtext(Time FE, YES, Region FE, YES)

	qui logit onset_2 MEAN_Level L.peace_years i.GID_1_encoded i.year i.month if onset_2_variation >0, vce(cluster iso_encoded)
	outreg2 using "../../Manuscript/Regression_alternative_monthly_2.doc", append ctitle(Model 9 - Logit) keep(MEAN_Level L.peace_years)  addstat(Pseudo R-squared, e(r2_p), Degrees of Freedom, e(df_m)) label  addtext(Time FE, YES, Region FE, YES)

**** Model 10: Multilevel model linear regression
	xtmixed conflict_incidence MEAN_Level L.peace_years ln_gnic ln_pop ln_lifexp || iso_encoded:, mle nolog covariance(unstructured)
	outreg2 using "../../Manuscript/Regression_alternative_monthly_2.doc", append  ctitle(Model 10 - Hierarchical linear model with controls)  label addtext(Time FE, NO, Region FE, NO)
	
	xtmixed onset_2 MEAN_Level L.peace_years ln_gnic ln_pop ln_lifexp || iso_encoded:, mle nolog covariance(unstructured)
	outreg2 using "../../Manuscript/Regression_alternative_monthly_2.doc", append ctitle(Model 10 - Hierarchical linear model with controls)  label addtext(Time FE, NO, Region FE, NO)

	
**** Model 11: Spatial Auto-regressive Model (SAR)
	*Creating a spatial weight matrix
	spmatrix create contiguity M if time_id== 5, normalize(row) replace
	
	*Performing the regressions
	spxtregress conflict_incidence MEAN_Level L_peace_year if conflict_variation > 0, fe dvarlag(M) errorlag(M) force
	outreg2 using "../../Manuscript/Regression_alternative_monthly_2.doc", append ctitle(Model 11 - SAR) keep(MEAN_Level L.peace_years ) addstat(Pseudo R-squared, e(r2_p), Degrees of Freedom, e(df_m)) label addtext(Time FE, YES, Region FE, NO)

	spxtregress onset_2 MEAN_Level L_peace_year if onset_2_variation> 0, fe dvarlag(M) errorlag(M) force
	outreg2 using "../../Manuscript/Regression_alternative_monthly_2.doc", append ctitle(Model 11 - SAR) keep(MEAN_Level L.peace_years) addstat(Pseudo R-squared, e(r2_p), Degrees of Freedom, e(df_m)) label addtext(Time FE, YES, Region FE, NO)

**** Model 12: Block bootstrap standard-errors
	bootstrap, reps(500) cluster(iso_encoded) idcluster(IDD) group(_ID) seed(10): xtreg conflict_incidence MEAN_Level L.peace_years i.time_id, fe vce(r)
	outreg2 using "../../Manuscript/Regression.doc", append ctitle(Model 12)  label addtext(Time FE, YES, Region FE, YES)
	
	bootstrap, reps(500) cluster(iso_encoded) idcluster(IDD) group(_ID) seed(10): xtreg onset_2 MEAN_Level L.peace_years i.time_id, fe vce(r)
	outreg2 using "../../Manuscript/Regression_SR.doc", append ctitle(Model 12) label addtext(Time FE, YES, Region FE, YES)
		

	
************************************************************
*Table S8 : Regressions with alternative conflict definition
************************************************************
	
**** Model 13: All types of conflicts
	reghdfe conflict_incidence_any MEAN_Level L.peace_years, absorb(_ID time_id)  vce(cluster iso_encoded)
	outreg2 using "../../Manuscript/Regression_alternative_monthly_3.doc", replace ctitle(Model 13 - All types of conflcit) e(all) label addtext(Time FE, YES, Region FE, YES)	

	reghdfe onset_any_2 MEAN_Level L.peace_years, absorb(_ID time_id)  vce(cluster iso_encoded)
	outreg2 using "../../Manuscript/Regression_alternative_monthly_3.doc", append ctitle(Model 13 - All types of conflcit) e(all) label addtext(Time FE, YES, Region FE, YES)
	
****  Model 15: Analysis using ACLED data - ACLED conflict data record are available from 1997
	reghdfe conflict_inc_ACLED MEAN_Level L.peace_years if year >=1997, absorb(GID_1 time_id)  vce(cluster iso_encoded)
	outreg2 using "../../Manuscript/Regression_alternative_monthly_3.doc", append ctitle(Model 14 - ACLED conflicts) e(all) label addtext(Time FE, YES, Region FE, YES)
	
	reghdfe onset_ACLED MEAN_Level L.peace_years if year >=1997, absorb(GID_1 time_id) vce(cluster iso_encoded)
	outreg2 using "../../Manuscript/Regression_alternative_monthly_3.doc", append ctitle(Model 14  - ACLED conflicts) e(all) label addtext(Time FE, YES, Region FE, YES)
	
****  Model 16: Analysis at the country level
	collapse conflict_incidence MEAN_Level onset_2 (firstnm) iso (min) peace_years, by(iso_encoded year month time_id)
	xtset iso_encoded time_id

	reghdfe conflict_incidence MEAN_Level L.peace_years, absorb(iso_encoded time_id) vce(r)
	outreg2 using "../../Manuscript/Regression_alternative_monthly_3.doc", append ctitle(Model 15 - country incidence) e(all) label addtext(Time FE, YES, Country FE, YES)

	reghdfe onset_2 MEAN_Level L.peace_years, absorb(iso_encoded time_id) vce(r)
	outreg2 using "../../Manuscript/Regression_alternative_monthly_3.doc", append ctitle(Model 15 - country onset) e(all) label addtext(Time FE, YES, Country FE, YES)

**** Reloading the data at the regional level
	use regression_file_monthly, clear



*****************************************************
*Table S10 : with 5 years defintion of conflict onset
*****************************************************

reghdfe onset_5 MEAN_Level  L.peace_years, absorb(iso_encoded time_id) vce(cluster iso_encoded)
outreg2 using "../../Manuscript/Regression_alternative_onset.doc", replace ctitle(Model 1 - monthly) label addtext(Time FE, YES, Country FE, YES)



*******************************************************************	
*Figure 1: Regressions with leads and lags of rainfall observations
*******************************************************************
	*Precipitation on conflict incidence and onset with 6 months lead and lag variables
	sort _ID time_id
	reghdfe conflict_incidence F(6/1).MEAN_Level L(0/6).MEAN_Level L.peace_years, absorb(GID_1 time_id) vce(cluster iso_encoded)
	estimates store Inc
	reghdfe onset_2 F(6/1).MEAN_Level L(0/6).MEAN_Level L.peace_years, absorb(GID_1 time_id) vce(cluster iso_encoded)
	estimates store Ons
	coefplot Inc, bylabel( Conflict incidence (m)) ///
		   || Ons, bylabel(Conflict onset (m)) ///
		   ||, drop(_cons L.peace_years) xline(0) levels(99 95) ///
		   xlabel(-0.000005 "-0.0005%" 0 "0"  0.000005 "0.0005%", labsize(vsmall)) ///
		    coeflabels(L.MEAN_Level = "Rainfall (m-1)" L2.MEAN_Level = "Rainfall (m-2)" ///
			L3.MEAN_Level = "Rainfall (m-3)" L4.MEAN_Level = "Rainfall (m-4)" ///
			L5.MEAN_Level = "Rainfall (m-5)" L6.MEAN_Level = "Rainfall (m-6)" ///
			F.MEAN_Level = "Rainfall (m+1)" F2.MEAN_Level = "Rainfall (m+2)" ///
			F3.MEAN_Level = "Rainfall (m+3)" F4.MEAN_Level = "Rainfall (m+4)" ///
			F5.MEAN_Level = "Rainfall (m+5)" F6.MEAN_Level = "Rainfall (m+6)" ///
			MEAN_Level = "Rainfall (m)", labsize(small))
			
	graph export "../../Manuscript/Graph_regession_leads_lags.png", width(5000) replace
	
********************************************************************************
*Figure S2: Regressions with leads and lags of rainfall observations for Africa
********************************************************************************
	*Precipitation on conflict incidence and onset with 6 months lead and lag variables
	sort _ID time_id
	reghdfe conflict_incidence F(6/1).MEAN_Level L(0/6).MEAN_Level L.peace_years, absorb(GID_1 time_id) vce(cluster iso_encoded)
	estimates store Inc
	reghdfe onset_2 F(6/1).MEAN_Level L(0/6).MEAN_Level L.peace_years, absorb(GID_1 time_id) vce(cluster iso_encoded)
	estimates store Ons
	coefplot Inc, bylabel( Conflict incidence (m)) ///
		   || Ons, bylabel(Conflict onset (m)) ///
		   ||, drop(_cons L.peace_years) xline(0) levels(99 95) ///
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

	
	
*********************************************
*Table S11 : with lag values of precipitation
*********************************************
	sort _ID time_id
	reghdfe conflict_incidence MEAN_Level L.peace_years, absorb(GID_1_encoded time_id) vce(cluster iso_encoded)
	outreg2 using "../../Manuscript/Regression_lags_month.doc", replace ctitle(Model 16) label addtext(Year FE, YES, Region FE, YES)	

	reghdfe onset_2 MEAN_Level L.peace_years, absorb(GID_1 time_id)  vce(cluster iso_encoded)
	outreg2 using "../../Manuscript/Regression_lags_month.doc", append ctitle(Model 16) label addtext(Year FE, YES, Region FE, YES)

	reghdfe conflict_incidence L.MEAN_Level L.peace_years, absorb(GID_1_encoded time_id) vce(cluster iso_encoded)
	outreg2 using "../../Manuscript/Regression_lags_month.doc", append ctitle(Model 17) label addtext(Year FE, YES, Region FE, YES)	

	reghdfe onset_2 L.MEAN_Level L.peace_years, absorb(GID_1_encoded time_id) vce(cluster iso_encoded)
	outreg2 using "../../Manuscript/Regression_lags_month.doc", append ctitle(Model 17) label addtext(Year FE, YES, Region FE, YES)	

	reghdfe conflict_incidence L(0/11).MEAN_Level L.peace_years, absorb(GID_1_encoded time_id) vce(cluster iso_encoded)
	outreg2 using "../../Manuscript/Regression_lags_month.doc", append ctitle(Model 18) label addtext(Year FE, YES, Region FE, YES)	

	reghdfe onset_2 L(0/11).MEAN_Level L.peace_years, absorb(GID_1_encoded time_id) vce(cluster iso_encoded)
	outreg2 using "../../Manuscript/Regression_lags_month.doc", append ctitle(Model 18) label addtext(Year FE, YES, Region FE, YES)
