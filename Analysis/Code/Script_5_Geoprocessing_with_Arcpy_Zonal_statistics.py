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
GADM_GID_1_shp = "Temporary/GADM_GID_1.shp"
zone_field = "GID_1"
GADM_GID_1_dbf = "Temporary/GADM_GID_1.dbf"

## Geoprocessing starts here ##
try:
    print("Lopping over the data for zonal statistics")
    # Looping over the data types
    for i in ["annual","monthly"]:
        # Defining local variables
        if i =="annual":
            Input_folder = "Temporary/Rainfall monthly"
            Output_folder = "Zonal_stat_monthly"
        else:
            Input_folder = "Temporary/Rainfall_annual"
            Output_folder = "Zonal_stat_annual"

        # Creating the directory of the output of zonal statistics
        parent_dir  = str(os.getcwd()) + "/Temporary/"
        path = os.path.join(parent_dir, Output_folder)
        print("Creating the directory '% s'" % Output_folder)
        if not os.path.exists(path):
            os.mkdir(path)
        
        #Defining the inner variables of the loop
        print("Defining the variables inside the loop")
        arcpy.env.workspace = Input_folder
        Raster_list = arcpy.ListRasters("chirps*", "TIF")
        
        # Zonal statistics for GID_1
        for raster in Raster_list:
            # Set inner variables
           
            raster_id = raster[7:14]
            out_table = path +"/table_"+raster_id+".dbf"
            print("Working on raster "+raster_id)
            arcpy.sa.ZonalStatisticsAsTable(GADM_GID_1_shp, zone_field, raster, out_table, "DATA", "ALL")
            
        print("Everything ended fine for "+i+" rasters")

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
