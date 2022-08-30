# Scripts for geoprocessing processing analysis with Arcpy #

print("Setting the working directory")
import os
work_dir = os.path.dirname(os.path.realpath(__file__))
os.chdir(work_dir)
os.chdir("..")
print(os.getcwd())

# Importing libraries
print("Launching ArcGIS")
import arcpy
import sys
from arcpy.sa import *

# Setting up the environment
## To allow overwriting outputs change overwriteOutput option to True.
print("Enabling spatial analysis extentions")
arcpy.env.overwriteOutput = True
arcpy.CheckOutExtension("spatial")

## Setting the inner variables
print("Setting up the variables")
GADM_shp = "Input/gadm/gadm404.shp"
zone_field = "GID_1"
GADM_GID_1_shp = "Temporary/GADM_GID_1.shp"
UCDP_GED_xlsx = os.getcwd() + "/" + "Input/ged211/ged211.xlsx"
UCDP_GED_dbf = os.getcwd() + "/" + "Temporary/ged211.dbf"
UCDP_shp = os.getcwd() + "/" + "Temporary/Armed_conflicts_UCDP.shp"
UCDP_joined_GID_1_shp = os.getcwd() + "/" + "Temporary/GID_1_joined_UCDP.shp"
UCDP_joined_GID_1_dbf = os.getcwd() + "/" + "Temporary/GID_1_joined_UCDP.dbf"
UCDP_joined_GID_1_xlsx = os.getcwd() + "/" + "Output/GID_1_joined_UCDP.xlsx"
ACLED_geo_data_xlsx = os.getcwd() + "/" + "Temporary/ACLED_Armed_conflicts.xlsx"
ACLED_geo_data_dbf = os.getcwd() + "/" + "Temporary/ACLED.dbf"
ACLED_shp = os.getcwd() + "/" + "Temporary/ACLED.shp"
ACLED_joined_GID_1_shp = os.getcwd() + "/" + "Temporary/GID_1_joined_ACLED.shp"
ACLED_joined_GID_1_dbf = os.getcwd() + "/" + "Temporary/GID_1_joined_ACLED.dbf"
ACLED_joined_GID_1_xlsx = os.getcwd() + "/" + "Output/GID_1_joined_ACLED.xlsx"

## Geoprocessing starts here ##
try:

##    # Converting the UCDP excel to dbase format
##    ## Process: Conversion excel to table
##    print("Converting the UCDP excel to dbase format")
##    arcpy.ExcelToTable_conversion(UCDP_GED_xlsx, UCDP_GED_dbf)
##
##    # Creating a UCDP layer based on the coordinates
##    ## Process: Make xy event layer fo the UCDP file
##    print("Make XY event layer of armed conflicts based on reported latitude and longitude/ the projection of the file is WGS84")
##    factorycode = 4326
##    cs = arcpy.SpatialReference(factorycode)
##    arcpy.management.MakeXYEventLayer(UCDP_GED_dbf, "longitude", "latitude", "UCDP_Layer", cs, None)
##
##    ## Process: Copy layer
##    print("Copy the conflict layer as a shapefile on the disk")
##    arcpy.management.CopyFeatures("UCDP_Layer", UCDP_shp)
##
##    ## Process: Dissolving the shapefile
##    ## Dissolving the GADM shapefile only it does not already exist in the disk
##    if os.path.exists(GADM_GID_1_shp):
##       print("GADM shapefile fields are dissolved")
##    else :
##        print("Dissolving the GADM shapefile fields")
##        arcpy.Dissolve_management(GADM_shp, GADM_GID_1_shp, zone_field)
##
##    ## Process: Spatial Join
##    print("Join the UCDP shapefile and the GADM shapefile at the first order national administrative units (refered as regions)")
##    arcpy.analysis.SpatialJoin(UCDP_shp, GADM_GID_1_shp, UCDP_joined_GID_1_shp, "JOIN_ONE_TO_ONE", "KEEP_ALL")
##
##    ## Process: Table to excel
##    print("Exporting the join output to excel as "+UCDP_joined_GID_1_xlsx)
##    arcpy.conversion.TableToExcel(UCDP_joined_GID_1_dbf, UCDP_joined_GID_1_xlsx, "NAME", "CODE")
##
##
##    # Converting the ACLED excel to dbase format
##    ## Process: Conversion excel to table
##    print("Converting the ACLED data excel to dbase format")
##    arcpy.ExcelToTable_conversion(ACLED_geo_data_xlsx, ACLED_geo_data_dbf)

    # Creating a UCDP layer based on the coordinates
    ## Process: Make xy event layer fo the UCDP file
    print("Make XY event layer of armed conflicts based on reported latitude and longitude/ the projection of the file is WGS84")
    factorycode = 4326
    cs = arcpy.SpatialReference(factorycode)
    arcpy.management.MakeXYEventLayer(ACLED_geo_data_dbf, "longitude", "latitude", "ACLED_Layer", cs, None)

    ## Process: Copy layer
    print("Copy the conflict layer as a shapefile on the disk")
    arcpy.management.CopyFeatures("ACLED_Layer", ACLED_shp)

    ## Process: Spatial Join
    print("Join the ACLED shapefile and the GADM shapefile at the first order national administrative units (refered as regions)")
    arcpy.analysis.SpatialJoin(ACLED_shp, GADM_GID_1_shp, ACLED_joined_GID_1_shp, "JOIN_ONE_TO_ONE", "KEEP_ALL")

    ## Process: Table to excel
    print("Exporting the join output to excel as "+UCDP_joined_GID_1_xlsx)
    arcpy.conversion.TableToExcel(UCDP_joined_GID_1_dbf, UCDP_joined_GID_1_xlsx, "NAME", "CODE")

   
    print("All geoprocessing sucessfully done")

#Return geoprocessing specific errors
##except arcpy.ExcuteError:
##    print(arcpy.Getmessage())
except Exception:
    e = sys.exc_info()[1]
    print(e.args[0])

    # If using this code within a script tool, AddError can be used to return messages 
    #   back to a script tool. If not, AddError will have no effect.
    arcpy.AddError(e.args[0])

#Return any other type of error
except:
    print("There is no geoprocessing error.")
    
### Release the memory ###
print("Closing ArcGIS")
del arcpy
