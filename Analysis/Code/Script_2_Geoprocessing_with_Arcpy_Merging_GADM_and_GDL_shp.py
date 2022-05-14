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
GADM_GID_1_shp = "Temporary/GADM_GID_1.shp"
GADM_GID_1_dbf = "Temporary/GADM_GID_1.dbf"
input_centroids = os.getcwd() + "/" +GADM_GID_1_shp
input_XY_event_layer = os.getcwd() + "/" + GADM_GID_1_dbf
zone_field = "GID_1" #the level of data that is used as spatial unit for the analysis
GID_1_centroids = "Temporary/GID_1_centroids.shp"
GDL_shp = "Input/GDL/GDL Shapefiles V4.shp"
GID_1_join_GDL_shp = "Temporary/GID_1_X_GDL_id.shp"
GID_1_join_GDL_dbf = os.getcwd() + "/" + "Temporary/GID_1_X_GDL_id.dbf"
GID_1_join_GDL_xls = os.getcwd() + "/" + "Output/GID_1_X_GDL_id.xlsx"

## Geoprocessing starts here ##
try:
    ## Process: Dissolving the shapefile
    print("Dissolving the shapefile fields")
    arcpy.Dissolve_management(GADM_shp, GADM_GID_1_shp, zone_field)

    # Process: Generate the extent coordinates using Add Geometry Properties tool
    print('Generating the centroids of the GADM shapefile')
    factorycode = 4326
    cs = arcpy.SpatialReference(factorycode)
    arcpy.AddGeometryAttributes_management(input_centroids, "CENTROID", "KILOMETERS", "SQUARE_KILOMETERS", cs)

    # Merging the GDL maps with the GADM
    ## Process: Make xy event layer fo the GADM file
    print("Make XY event layer from GADM to extract the centroids")
    arcpy.MakeXYEventLayer_management(input_XY_event_layer, "CENTROID_X", "CENTROID_Y", "gadm36_GID_1_Layer", cs, None)

    # Merging the GDL maps with the GADM
    ## Process: Make xy event layer fo the GADM file
    print("Make XY event layer from GADM to extract the centroids")
    arcpy.management.CopyFeatures("gadm36_GID_1_Layer", GID_1_centroids)

    ## Process: Joining the centroids of the GADM layer witht GDL shapefile
    print("Join GADM and GDL maps")
    arcpy.analysis.SpatialJoin(GID_1_centroids, GDL_shp, GID_1_join_GDL_shp, "JOIN_ONE_TO_ONE", "KEEP_ALL")

    ## Process: Exporting the output join to excel
    print("Exporting the join output to excel")
    arcpy.conversion.TableToExcel(GID_1_join_GDL_dbf, GID_1_join_GDL_xls, "NAME", "CODE")
   
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
