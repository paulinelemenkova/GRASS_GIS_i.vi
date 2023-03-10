#!/bin/sh
# raster metadata:
r.info -r LC08_L2SP_189056_20181220_20200912_02_T1_SR_B1
# checking the selected random band
gdalinfo LC08_L2SP_189056_20181220_20200912_02_T1_SR_B7.TIF
# importing the image subset with 7 Landsat bands and display the raster map (polinalemenkova)
r.in.gdal LC08_L2SP_189056_20180201_20200902_02_T1_SR_B1.TIF out=L8_2018_01 --overwrite
r.in.gdal LC08_L2SP_189056_20180201_20200902_02_T1_SR_B2.TIF out=L8_2018_02 --overwrite
r.in.gdal LC08_L2SP_189056_20180201_20200902_02_T1_SR_B3.TIF out=L8_2018_03 --overwrite
r.in.gdal LC08_L2SP_189056_20180201_20200902_02_T1_SR_B4.TIF out=L8_2018_04 --overwrite
r.in.gdal LC08_L2SP_189056_20180201_20200902_02_T1_SR_B5.TIF out=L8_2018_05 --overwrite
r.in.gdal LC08_L2SP_189056_20180201_20200902_02_T1_SR_B6.TIF out=L8_2018_06 --overwrite
r.in.gdal LC08_L2SP_189056_20180201_20200902_02_T1_SR_B7.TIF out=L8_2018_07 --overwrite
r.in.gdal LC08_L2SP_189056_20180201_20200902_02_T1_ST_EMIS out=L8_2018_08 --overwrite
r.in.gdal LC08_L2SP_189056_20180201_20200902_02_T1_ST_EMSD.TIF out=L8_2018_09 --overwrite
r.in.gdal LC08_L2SP_189056_20180201_20200902_02_T1_ST_B10.TIF out=L8_2018_10 --overwrite
r.in.gdal LC08_L2SP_189056_20180201_20200902_02_T1_ST_TRAD.TIF out=L8_2018_11 --overwrite
# listing the files
g.list rast
# preprocessing:
# copying the Landsat bands to match the input structure of the i.landsat.toar
g.copy raster=L8_2018_01,lsat8_2018.1 --overwrite
g.copy raster=L8_2018_02,lsat8_2018.2 --overwrite
g.copy raster=L8_2018_03,lsat8_2018.3 --overwrite
g.copy raster=L8_2018_04,lsat8_2018.4 --overwrite
g.copy raster=L8_2018_05,lsat8_2018.5 --overwrite
g.copy raster=L8_2018_06,lsat8_2018.6 --overwrite
g.copy raster=L8_2018_07,lsat8_2018.7 --overwrite
g.copy raster=L8_2018_08,lsat8_2018.8 --overwrite
g.copy raster=L8_2018_09,lsat8_2018.9 --overwrite
g.copy raster=L8_2018_10,lsat8_2018.10 --overwrite
g.copy raster=L8_2018_11,lsat8_2018.11 --overwrite
# converting the DN pixel values to reflectance values using DOS1. From Digital Numer (DN) to reflectance. Before creating an RGB composite, it is important to convert the digital number data (DN) to reflectance (or optionally radiance). Otherwise the colors of a “natural” RGB composite do not look convincing but rather hazy (see background in the next screenshot). This conversion is done using the metadata file which is included in the data set with i.landsat.toar # i.landsat.toar - Calculates top-of-atmosphere radiance or reflectance and temperature for Landsat MSS/TM/ETM+/OLI
i.landsat.toar input=lsat8_2018. output=lsat8_2018_toar. sensor=oli8 \
    method=dos1 date=2018-02-01 sun_elevation=52.98824638 \
    product_date=2020-09-02 gain=HHHLHLHHL --overwrite
#
# Calculation of VI
#
# 1. Calculation of NDVI
g.region raster=lsat8_2018_toar.4 -p
i.vi red=lsat8_2018_toar.4 nir=lsat8_2018_toar.5 viname=ndvi \
       output=lsat8_2018.ndvi --overwrite
r.colors lsat8_2018.ndvi color=ndvi
# displaying the map
d.mon wx0
g.region raster=lsat8_2018_toar.4 -p
d.rast lsat8_2018.ndvi
d.legend raster=lsat8_2018.ndvi range=-1,1 title="NDVI" title_fontsize=14 font=Helvetica fontsize=12 -t -s -b border_color=white thin=12 label_step=0.1 -d
d.out.file output=Nigeria_NDVI_2018 format=jpg --overwrite
#
# 2. Calculation of ARVI
# ARVI = (nirchan - (2.0*redchan - bluechan)) / ( nirchan + (2.0*redchan - bluechan))
g.region raster=lsat8_2018_toar.3 -p
i.vi blue=lsat8_2018_toar.2 red=lsat8_2018_toar.4 nir=lsat8_2018_toar.5 \
       viname=arvi output=lsat8_2018.arvi --overwrite
r.colors lsat8_2018.arvi color=bcyr -e
# r.colors --help
d.mon wx0
d.rast lsat8_2018.arvi
d.legend raster=lsat8_2018.arvi range=-0.7,0.3 title="ARVI" title_fontsize=14 font=Helvetica fontsize=12 -t -s -b border_color=white thin=12 label_step=0.1 -d
d.out.file output=Nigeria_ARVI_2018 format=jpg --overwrite
#
# 3. Calculation of GARI
# GARI = (nirchan - (2.0*redchan - bluechan)) / ( nirchan + (2.0*redchan - bluechan))
g.region raster=lsat8_2018_toar.3 -p
i.vi blue=lsat8_2018_toar.2 green=lsat8_2018_toar.3 red=lsat8_2018_toar.4 \
     nir=lsat8_2018_toar.5 viname=gari output=lsat8_2018.gari --overwrite
r.colors lsat8_2018.gari color=rainbow -e
# r.colors --help
d.mon wx1
d.rast lsat8_2018.gari
d.legend raster=lsat8_2018.gari range=-0.5,0.7 title="GARI" title_fontsize=14 font="Helvetica" fontsize=12 -t -b bgcolor=white label_step=0.1 border_color=white thin=8 -d
d.out.file output=Nigeria_GARI_2018 format=jpg --overwrite
#
# 4. Calculation of GVI (Green Vegetation Index - Tasseled Cap)
g.region raster=lsat8_2018_toar.3 -p
i.vi blue=lsat8_2018_toar.2 green=lsat8_2018_toar.3 red=lsat8_2018_toar.4 nir=lsat8_2018_toar.5 band5=lsat8_2018_toar.6 band7=lsat8_2018_toar.7 viname=gvi output=lsat8_2018.gvi --overwrite
# r.colors --help
r.colors.stddev lsat8_2018.gvi
d.mon wx0
d.rast lsat8_2018.gvi
d.legend raster=lsat8_2018.gvi range=-1,0.7 title="GVI" title_fontsize=14 font="Helvetica" fontsize=12 -t -b bgcolor=white label_step=0.1 border_color=white thin=8 -d
d.out.file output=Nigeria_GVI_2018 format=jpg --overwrite
#
# 5. Calculation of DVI (Difference Vegetation Index)
g.region raster=lsat8_2018_toar.1 -p
i.vi blue=lsat8_2018_toar.2 red=lsat8_2018_toar.4 nir=lsat8_2018_toar.5 viname=dvi output=lsat8_2018.dvi --overwrite
r.colors lsat8_2018.dvi color=bgyr -e
# r.colors --help
d.mon wx0
d.rast lsat8_2018.dvi
d.legend raster=lsat8_2018.dvi range=-0.1,0.3 title="DVI" title_fontsize=14 font="Helvetica" fontsize=12 -t -b bgcolor=white label_step=0.02 border_color=white thin=8 -d
d.out.file output=Nigeria_DVI_2018 format=jpg --overwrite
#
# 6. Calculation of PVI (Perpendicular Vegetation Index)
g.region raster=lsat8_2018_toar.1 -p
i.vi red=lsat8_2018_toar.4 nir=lsat8_2018_toar.5 viname=pvi output=lsat8_2018.pvi --overwrite
r.colors lsat8_2018.pvi color=byr -e
# r.colors --help
d.mon wx0
d.rast lsat8_2018.pvi
d.legend raster=lsat8_2018.pvi range=-0.1,0.3 title="PVI" title_fontsize=14 font="Helvetica" fontsize=12 -t -b bgcolor=white label_step=0.02 border_color=white thin=8 -d
d.out.file output=Nigeria_PVI_2018 format=jpg --overwrite
#
# RGB colour composites
# False composite 5-4-3
r.composite blue=L8_2018_05 green=L8_2018_04 red=L8_2018_03 output=L8_2018_RGB --overwrite
# Natural colours 4-3-2
r.composite blue=L8_2018_02 green=L8_2018_03 red=L8_2018_04 output=L8_2018_RGB --overwrite
# visualizing the RGB triplet
d.mon wx0
g.region raster=L8_2018_RGB -p
gdalinfo LC08_L2SP_189056_20181220_20200912_02_T1_SR_B7.TIF
# r.colors --help
r.colors L8_2018_RGB col=grass
d.rast L8_2018_RGB

