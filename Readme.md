# The impact of rainfall variability on conflict outbreaks at the monthly level

Replication materials for the manuscript `The impact of rainfall variability on conflict outbreaks at the monthly level'.

The materials in this repository allow users to reproduce the statistical analyses appearing in the main text and extended data of the manuscript.

If you find meaningful errors in the code or have questions or suggestions, please contact Thierry Yerema Coulibaly at yerema.coul@gmail.com


## Organization of repository

* **Analysis/code**: folder for scripts for downloading, processing and replication of the data, as well as for the statistical analysis.
* **Analysis/Input**: folder for data inputs for analysis.
* **Analysis/Temporary**: folder for data manipulation during the processing of the data.
* **Analysis/Output**: folder for data after processing
* **Analysis/Output/regression_file_CHIRPS_precipitation_monthly.dta **: Replication of main dataset for analysis at the monthly level.
* **Analysis/Output/regression_file_CHIRPS_precipitation.dta **: Replication of main dataset for analysis at the annual level.


***A couple of notes on replication:***


* **A note about replication with ACLED and globaldatalab data**: Ideally we would like to provide replication materials for the entire pipeline beginning with the raw publicly available data and ending with the results presented in the manuscript. However, due to the [ACLED data use agreement](https://acleddata.com/data-export-tool/) and [global data lab use agreement] https://globaldatalab.org/, we cannot post their data in an online repository. Nonetheless, we included information of the ACLED data after their porcessing in the replication dataset. For any issues regarding construction of the DHS sample contact Sam at yerema.coul@gmail.com. 

* **A note about the version of the PM2.5 data set used in the analysis**: A few weeks before our paper was published a [new version](http://fizz.phys.dal.ca/~atmos/martin/?page_id=140#V4.GL.03) of the PM2.5 data set that we used was released (V4.GL.03). In our paper we used the previous data release (V4.GL.02) which was the newest available data at the time. Among several changes made to the data, handling of PM2.5 from dust was improved in the new release and this led to substantial differences in the PM2.5 concentrations estimated across West and North Africa. In fact, in the new version of the data, PM2.5 concentration estimates are on average approximately 20 ug/m3 lower across West and North Africa than they were in the previous release (see Fig 1D in the [paper](https://pubs.acs.org/doi/full/10.1021/acs.est.0c01764) that accompanies the new data release). 20 ug/m3 is a large difference, however, it should be noted that our analysis does not rely on the concentration levels themselves. Because we estimate a linear model and include location fixed effects (dummies) our approach leverages variation in the deviations from long-run averages in each location and these deviations are much more stable across data releases than the concentration levels. That being said, when we re-run our analysis with the new data release the magnitudes of our estimates do change (most coefficient magnitudes are within +/- 15% but some vary by as much +/- 30%). All estimates using the new data fall within the confidence intervals presented in the paper and all estimates remain statistically different from zero.  
    
    In summary, our analysis used a previous release of the PM2.5 data and a new and improved version is now available. Re-running our analysis with the new data produces some variation in effect magnitudes but all of the same conclusions. All replication materials presented here utilize the previous data release used in the paper. All future applications (apart from replication) should utilize the newer version of the data.

## Instructions

***Overview of the main replication materials:***

The repository is ~360Mb (and >2Gb if you download all the raw data using script 00)

Users can manage replication through the R project "NatSus2020_replication.Rproj". Alternatively users can set working directory to NatSus2020 and run scripts independently.

* **data/inputs/analysis_data.rds** This file includes the final processed data used in the analysis with all location identifying information removed. This file can be used to replicate the results in the paper but because identifying information has been removed, it cannot be used to replicate pre-processing since those steps require linking exposures to individual DHS observations based on location and timing of births.

* **data/inputs/dhs/dhs_locations.csv** This file includes the locations of all DHS clusters included in the analysis. All information that could be used to link the locations to the birth data has been removed. However, this file is used in the replication materials for some figures that do calculations at the locations of DHS clusters but do not involve the birth data (e.g., figure 5). Moreover, this file will also eventually be used to replicate all but the final step of pre-processing the exposure data using Script 19. When we were doing data processing for the paper we only processed exposures for the years and months we observed births in each location. However, if we provide birth year and birth months by location then it would be possible to identify locations for some of the observations. We are therefore working on re-writing our code to process exposures for all DHS locations for all location-birth year-birth month combinations. This would then allow full replication from raw data through results with the exception of a single line of code joining exposures with birth data on cluster_id, child_birth_year, and child_birth_month. However, the revised process required to maintain anonymity would necessitate processing nearly 6 million rows of data instead of the approximately 750K rows that we actually processed (since we ignored year-month-location combinations without observations) so still working on this.

* **data/inputs/dhs/dhs_surveys.csv** This is a list of surveys included in the analysis. In order to replicate our sample from the raw DHS data you would need to first [register](https://dhsprogram.com/data/new-user-registration.cfm) for access to the data, then you could use this csv file to identify the relevant surveys to [download](https://dhsprogram.com/data/available-datasets.cfm). Reshaping the individual recode (IR) files to be at the birth level, appending all surveys, subsetting to births that occurred between 2001 and 2015, and dropping children that were alive for less than 12 months at the time of survey should reproduce our sample. For questions on any of these steps contact Sam at yerema.coul@gmail.com.

* **data/inputs/** Includes a combination of empty directories that are populated when running script 00 and directories with pre-processed data that are not used in the main analysis but are used for generating some components of figures.

* **Scripts**

    Script 01 downloads the CHIRPs rainfall rasters data and handling missing values (script 00 must be run first)

    Script 02 downloads the GADM, GDL and UCDP/GED shapefiles data

    Script 03 merges the GADM and GDL shapefiles data

    Script 04 merges the GADM and UCDP/GED shapefiles data

    Script 05 processes the zonal statistics of the rainfall CHRIPS raster data by GADM shapefile

    Script 06 downloads the GNI per capita and the SHDI-SGDI data

    Script 07 imports the UCDP/GED data

    Script 08 processes the monthly rainfall variables for statistical analysis in stata

    Script 09 processes the yearly rainfall variables for statistical analysis in stata

    Script 10 performs the monthly statistical analysis

    Script 11 performs the yearly statistical analysis


## R packages required

* **sp**
* **raster**
* **rgdal**
* **sf**
* **terra**
* **R.utils**

Scripts were written with R 3.6.3

## python packages required

* **arcpy**

Scripts were written with python 3.6

## Stata packages required

* **reghdfe**
* **kountry**
* **outreg2**
* **autorename**

Scripts were written with Stata 16.1 for MAC
