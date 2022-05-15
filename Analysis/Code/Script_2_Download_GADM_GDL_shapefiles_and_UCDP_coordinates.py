#!/usr/bin/env python3
# -*- coding: utf-8 -*-

print('Importing the modules')
import os
import requests
import zipfile

print('Setting the working directory')
work_dir = os.path.dirname(os.path.realpath(__file__))
os.chdir(work_dir)

# Importing GADM and GDL data
Data_source_GDL = 'https://geodata.ucdavis.edu/gadm/gadm4.0/gadm404-shp.zip'
Data_source_GADM = 'https://globaldatalab.org/assets/2020/03/GDL%20Shapefiles%20V4.zip'
Data_source_UCDP_GED_211 = 'https://ucdp.uu.se/downloads/ged/ged211-xlsx.zip'

print('Looping over the shapefiles to be downloaded')
for i in ['GADM','GDL','ged211']:
    if i == 'GADM':
        URL = Data_source_GADM
    elif i =='GDL':
        URL = Data_source_GDL
    else:
        URL = Data_source_UCDP_GED_211

    file_zip = str(i)+'.zip'
    file_unzip = '../Input/'+str(i)
    
    if os.path.exists(file_unzip):
        print("The % has been already downloaded!" % i)
    else :
        print('Working on '+str(i))
        print('Setting up variables')
        file_zip = str(i)+'.zip'
        file_unzip = '../Input/'+str(i)

        ## Downloading the data
        print('Importing '+i+' data')
        response = requests.get(URL)
        open(file_zip, 'wb').write(response.content)

        ## Unzipping the data
        print('Unzipping the data in the input folder')
        with zipfile.ZipFile(file_zip) as zip_ref: zip_ref.extractall(file_unzip)

        ## Removing the zip data drom the code folder
        print('Removing the zip the file from the PC memory')
        if os.path.exists(file_zip):
            os.remove(file_zip)
            print('The file '+i+'  has been deleted successfully')
        else:
            print('The file does not exist!')

print('The script was performed sucessfully')
