## Importing libraries -------
library(sp)
library(raster) # package for raster manipulation
library(rgdal) # package for geospatial analysis
library('sf')
library("terra")
library("R.utils")

## Setting the working directory -----
  setwd(dirname(rstudioapi::getActiveDocumentContext()$path))
  setwd(dirname(getwd()))

## Downloading yearly rainfall data ----
  
## Creating a folder for annual rainfall data
folder <- "Temporary/Rainfall_annual"
if (file.exists(folder)) {
  cat("The folder already exists")
} else {
  dir.create(folder)
}
  
#Data download: https://data.chc.ucsb.edu/products/CHIRPS-2.0/africa_monthly/tifs/
#Accompanying paper: https://www.nature.com/articles/sdata201566 
for (y in 1989:2021){
  url <- paste("https://data.chc.ucsb.edu/products/CHIRPS-2.0/global_annual/tifs/chirps-v2.0.",y,".tif", sep  = "")
  destination <- paste("Temporary/Rainfall_annual/chirps_",y,".tif", sep ="")                    
  download.file(url = url, destfile = destination)
}

#Defining the list of rainfall data - Rainfall data source: https://chc.ucsb.edu/data
Grids_folder_input = "Temporary/Rainfall_annual/"
Grids_folder_output = "Temporary/Rainfall_annual/"

### Redefining NA values of precipitation raster ----
  grids <- list.files(Grids_folder_input, pattern = "*.tif$")
  for (i in grids) {
    print(paste0("Working on ", i," in ", "Temporary/Rainfall_annual/"))
    print(paste0("Working on ", i," in ", "Temporary/Rainfall_annual/"))    
    #Generating local variables
    path <- paste0(Grids_folder_input,"/",i)
    path_output <- paste0(Grids_folder_output,"/",i)
    a = raster(path)
    a <- setMinMax(a)
    a
    a[a < 0] <- NA
    r <- terra::writeRaster(a, path_output, format="GTiff", overwrite=TRUE)
  }

## Downloading monthly rainfall data ----

## Creating a folder for annual rainfall data
folder <- "Temporary/Rainfall_monthly"
if (file.exists(folder)) {
  cat("The folder already exists")
} else {
  dir.create(folder)
}

#Data download: https://data.chc.ucsb.edu/products/CHIRPS-2.0/africa_monthly/tifs/
#Accompanying paper: https://www.nature.com/articles/sdata201566 
for (y in 1989:2021){
  for (m in 1:12){
    m <- formatC(m, width=2, flag="0")
    url <- paste("https://data.chc.ucsb.edu/products/CHIRPS-2.0/global_monthly/tifs/chirps-v2.0.",y,".",m,".tif.gz", sep  = "")
    destination_zip <- paste("Temporary/Rainfall_monthly/zip_",y,"_",m,".tif", sep ="")
    destination_tif <- paste("Temporary/Rainfall_monthly/chirps_",y,"_",m,".tif", sep ="")
    download.file(url = url, destfile = destination_zip)
    gunzip(destination_zip, destination_tif, overwrite=TRUE)
    unlink(destination_zip)
  }
}

## Redefining NA values of precipitation values ----
  Grids_folder_input = "Temporary/Rainfall_monthly"
  grids <- list.files(Grids_folder_input, pattern = "*.tif$")
  for (i in grids){
    print(paste0("Working on ", i))  
          #Generating local variables
          path <- paste0(Grids_folder_input,"/",i)
          path_output <- paste0(Grids_folder_output,"/",i)
          a = raster(path)
          a <- setMinMax(a)
          a
          a[a < 0] <- NA
          r <- terra::writeRaster(a, path_output, format="GTiff", overwrite=TRUE)
  }