#!/bin/sh
# raster metadata:
r.info -r LC08_L2SP_189056_20131220_20200912_02_T1_SR_B1
# checking the selected random band
gdalinfo LC08_L2SP_189056_20131220_20200912_02_T1_SR_B7.TIF
# importing the image subset with 7 Landsat bands and display the raster map (polinalemenkova)
r.in.gdal LC08_L2SP_189056_20131220_20200912_02_T1_SR_B1.TIF out=L8_2013_01
r.in.gdal LC08_L2SP_189056_20131220_20200912_02_T1_SR_B2.TIF out=L8_2013_02
r.in.gdal LC08_L2SP_189056_20131220_20200912_02_T1_SR_B3.TIF out=L8_2013_03
r.in.gdal LC08_L2SP_189056_20131220_20200912_02_T1_SR_B4.TIF out=L8_2013_04
r.in.gdal LC08_L2SP_189056_20131220_20200912_02_T1_SR_B5.TIF out=L8_2013_05
r.in.gdal LC08_L2SP_189056_20131220_20200912_02_T1_SR_B6.TIF out=L8_2013_06
r.in.gdal LC08_L2SP_189056_20131220_20200912_02_T1_SR_B7.TIF out=L8_2013_07
r.in.gdal LC08_L2SP_189056_20131220_20200912_02_T1_ST_B8.TIF out=L8_2013_08
r.in.gdal LC08_L2SP_189056_20131220_20200912_02_T1_ST_EMSD.TIF out=L8_2013_09 # Cirrus
r.in.gdal LC08_L2SP_189056_20131220_20200912_02_T1_ST_B10.TIF out=L8_2013_10 # TIRS 1
r.in.gdal LC08_L2SP_189056_20131220_20200912_02_T1_ST_TRAD.TIF out=L8_2013_11 # TIRS 2
# listing the files
g.list rast
# preprocessing:
# copying the Landsat bands to match the input structure of the i.landsat.toar
g.copy raster=L8_2013_01,lsat8_2013.1
g.copy raster=L8_2013_02,lsat8_2013.2
g.copy raster=L8_2013_03,lsat8_2013.3
g.copy raster=L8_2013_04,lsat8_2013.4
g.copy raster=L8_2013_05,lsat8_2013.5
g.copy raster=L8_2013_06,lsat8_2013.6
g.copy raster=L8_2013_07,lsat8_2013.7
g.copy raster=L8_2013_08,lsat8_2013.8
g.copy raster=L8_2013_09,lsat8_2013.9
g.copy raster=L8_2013_10,lsat8_2013.10
g.copy raster=L8_2013_11,lsat8_2013.11
# converting the DN pixel values to reflectance values using DOS1
i.landsat.toar input=lsat8_2013. output=lsat8_2013_toar. sensor=oli8 \
    method=dos1 date=2013-12-20 sun_elevation=51.85549756 \
    product_date=2013-12-20 gain=HHHLHLHHL
# Claculation of VI
# computing the NDVI
g.region raster=lsat8_2013_toar.4 -p
i.vi red=lsat8_2013_toar.4 nir=lsat8_2013_toar.5 viname=ndvi \
       output=lsat8_2013.ndvi
r.colors lsat8_2013.ndvi color=ndvi
# displaying the map
d.mon wx0
d.rast lsat8_2013.ndvi
# saving the file
d.out.file output=Nigeria_NDVI_2013 format=jpg --overwrite
    




# RGB composites: False composite
r.composite blue=L8_2013_05 green=L8_2013_04 red=L8_2013_03 output=L8_2013_RGB --overwrite
# natural colours
r.composite blue=L8_2013_04 green=L8_2013_03 red=L8_2013_02 output=L8_2013_RGB --overwrite
# visualizing the RGB triplet
d.mon wx0
g.region raster=L8_2013_RGB -p
gdalinfo LC08_L2SP_189056_20131220_20200912_02_T1_SR_B7.TIF
# r.colors --help
r.colors L8_2013_RGB col=grass
d.rast L8_2013_RGB
# From Digital Numer (DN) to reflectance. Before creating an RGB composite, it is important to convert the digital number data (DN) to reflectance (or optionally radiance). Otherwise the colors of a “natural” RGB composite do not look convincing but rather hazy (see background in the next screenshot). This conversion is done using the metadata file which is included in the data set with i.landsat.toar:
# i.landsat.toar - Calculates top-of-atmosphere radiance or reflectance and temperature for Landsat MSS/TM/ETM+/OLI
i.landsat.toar input=LC08_L2SP_189056_20131220_20200912_02_T1_SR_B7.TIF output=LC08_L2SP_189056_20131220_20200912_02_T1_SR_B7_toar \ metfile=LC08_L2SP_189056_20131220_20200912_02_T1_MTL.txt sensor=oli8 \ sun_elevation="51.85549756" date=2013-12-20 --overwrite
