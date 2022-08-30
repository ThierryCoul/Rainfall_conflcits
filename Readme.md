# The impact of rainfall variability on conflict outbreaks at the monthly level

Replication materials for the manuscript `The impact of rainfall variability on conflict outbreaks at the monthly level'.

The materials in this repository allow users to reproduce the statistical analyses appearing in the main text and extended data of the manuscript.

If you find meaningful errors in the code or have questions or suggestions, please contact Thierry Yerema Coulibaly at yerema.coul@gmail.com


## Organization of repository

* **Analysis/code**: folder for scripts for downloading, processing and replication of the data, as well as for the statistical analysis.
* **Analysis/Input**: folder for data inputs for analysis.
* **Analysis/Temporary**: folder for data manipulation during the processing of the data.
* **Analysis/Output**: folder for data after processing
* **Analysis/Manuscript**: folder for output of regression analyses
* **Analysis/Output/regression_file_monthly.dta**: Replication of main dataset for analysis at the monthly level.
* **Analysis/Output/regression_file_annually.dta**: Replication of main dataset for analysis at the annual level.


***Notes for replication:***

* **A note about replication with ACLED and globaldatalab data**: Ideally we would like to provide replication materials for the entire pipeline beginning with the raw publicly available data and ending with the results presented in the manuscript. However, due to the [ACLED data use agreement](https://acleddata.com/data-export-tool/) and [global data lab use agreement](https://globaldatalab.org/), we cannot post their data in an online repository. Our replication data excludes data from these sources.

## Instructions

***Overview of the main replication materials:***

The repository is ~357MB (and >6Gb if you download all the raw data)

* **Analysis/regression_file_CHIRPS_precipitation_monthly.dta** and **Analysis/regression_file_CHIRPS_precipitation_annually.dta** is a replication file of the data used in the main analysis. it can be used to check the results of the analysis of the manuscript without downloading  and preprocessing the raws data.

* **Analysis/Inputs** is an empty directory that is filled when running script 01 and 02.

* **Scripts**:

    Script 01 downloads the CHIRPs rainfall rasters data and handling missing values

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
