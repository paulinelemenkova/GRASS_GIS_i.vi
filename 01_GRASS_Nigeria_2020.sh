#!/bin/sh
# raster metadata:
r.info -r LC08_L2SP_189056_20201220_20200912_02_T1_SR_B1
# checking the selected random band
gdalinfo LC08_L2SP_189056_20201220_20200912_02_T1_SR_B7.TIF
# importing the image subset with 7 Landsat bands and display the raster map (polinalemenkova)
r.in.gdal LC08_L2SP_189056_20200122_20200823_02_T1_SR_B1.TIF out=L8_2020_01
r.in.gdal LC08_L2SP_189056_20200122_20200823_02_T1_SR_B2.TIF out=L8_2020_02
r.in.gdal LC08_L2SP_189056_20200122_20200823_02_T1_SR_B3.TIF out=L8_2020_03
r.in.gdal LC08_L2SP_189056_20200122_20200823_02_T1_SR_B4.TIF out=L8_2020_04
r.in.gdal LC08_L2SP_189056_20200122_20200823_02_T1_SR_B5.TIF out=L8_2020_05
r.in.gdal LC08_L2SP_189056_20200122_20200823_02_T1_SR_B6.TIF out=L8_2020_06
r.in.gdal LC08_L2SP_189056_20200122_20200823_02_T1_SR_B7.TIF out=L8_2020_07
r.in.gdal LC08_L2SP_189056_20200122_20200823_02_T1_ST_EMIS.TIF out=L8_2020_08
r.in.gdal LC08_L2SP_189056_20200122_20200823_02_T1_ST_EMSD.TIF out=L8_2020_09
r.in.gdal LC08_L2SP_189056_20200122_20200823_02_T1_ST_B10.TIF out=L8_2020_10
r.in.gdal LC08_L2SP_189056_20200122_20200823_02_T1_ST_TRAD.TIF out=L8_2020_11
# listing the files
g.list rast
# preprocessing:
# copying the Landsat bands to match the input structure of the i.landsat.toar
g.copy raster=L8_2020_01,lsat8_2020.1
g.copy raster=L8_2020_02,lsat8_2020.2
g.copy raster=L8_2020_03,lsat8_2020.3
g.copy raster=L8_2020_04,lsat8_2020.4
g.copy raster=L8_2020_05,lsat8_2020.5
g.copy raster=L8_2020_06,lsat8_2020.6
g.copy raster=L8_2020_07,lsat8_2020.7
g.copy raster=L8_2020_08,lsat8_2020.8
g.copy raster=L8_2020_09,lsat8_2020.9
g.copy raster=L8_2020_10,lsat8_2020.10
g.copy raster=L8_2020_11,lsat8_2020.11
# converting the DN pixel values to reflectance values using DOS1. From Digital Numer (DN) to reflectance. Before creating an RGB composite, it is important to convert the digital number data (DN) to reflectance (or optionally radiance). Otherwise the colors of a “natural” RGB composite do not look convincing but rather hazy (see background in the next screenshot). This conversion is done using the metadata file which is included in the data set with i.landsat.toar # i.landsat.toar - Calculates top-of-atmosphere radiance or reflectance and temperature for Landsat MSS/TM/ETM+/OLI
i.landsat.toar input=lsat8_2020. output=lsat8_2020_toar. sensor=oli8 \
    method=dos1 date=2020-01-22 sun_elevation=51.80702653 \
    product_date=2020-01-22 gain=HHHLHLHHL
#
# Calculation of VI
#
# 1. Calculation of NDVI
g.region raster=lsat8_2020_toar.4 -p
i.vi red=lsat8_2020_toar.4 nir=lsat8_2020_toar.5 viname=ndvi \
       output=lsat8_2020.ndvi --overwrite
r.colors lsat8_2020.ndvi color=ndvi
# displaying the map
d.mon wx0
g.region raster=lsat8_2020_toar.4 -p
d.rast lsat8_2020.ndvi
d.legend raster=lsat8_2020.ndvi range=-1,1 title="NDVI" title_fontsize=14 font=Helvetica fontsize=12 -t -s -b border_color=white thin=12 label_step=0.1 -d
d.out.file output=Nigeria_NDVI_2020 format=jpg --overwrite
#
# 2. Calculation of ARVI
# ARVI = (nirchan - (2.0*redchan - bluechan)) / ( nirchan + (2.0*redchan - bluechan))
g.region raster=lsat8_2020_toar.3 -p
i.vi blue=lsat8_2020_toar.2 red=lsat8_2020_toar.4 nir=lsat8_2020_toar.5 \
       viname=arvi output=lsat8_2020.arvi --overwrite
r.colors lsat8_2020.arvi color=haxby -e
# r.colors --help
d.mon wx1
d.rast lsat8_2020.arvi
d.legend raster=lsat8_2020.arvi range=-1.0,1.0 title="ARVI" title_fontsize=14 font=Helvetica fontsize=12 -t -s -b border_color=white thin=12 label_step=0.1 -d
d.out.file output=Nigeria_ARVI_2020 format=jpg --overwrite
#
# 3. Calculation of GARI
# GARI = (nirchan - (2.0*redchan - bluechan)) / ( nirchan + (2.0*redchan - bluechan))
g.region raster=lsat8_2020_toar.3 -p
i.vi blue=lsat8_2020_toar.2 green=lsat8_2020_toar.3 red=lsat8_2020_toar.4 \
     nir=lsat8_2020_toar.5 viname=gari output=lsat8_2020.gari --overwrite
r.colors lsat8_2020.gari color=rainbow -e
# r.colors --help
d.mon wx1
d.rast lsat8_2020.gari
d.legend raster=lsat8_2020.gari range=-0.5,0.7 title="GARI" title_fontsize=14 font="Helvetica" fontsize=12 -t -b bgcolor=white label_step=0.1 border_color=white thin=8 -d
d.out.file output=Nigeria_GARI_2020 format=jpg --overwrite
#
# 4. Calculation of GVI (Green Vegetation Index - Tasseled Cap)
g.region raster=lsat8_2020_toar.3 -p
i.vi blue=lsat8_2020_toar.2 green=lsat8_2020_toar.3 red=lsat8_2020_toar.4 nir=lsat8_2020_toar.5 band5=lsat8_2020_toar.6 band7=lsat8_2020_toar.7 viname=gvi output=lsat8_2020.gvi --overwrite
# r.colors --help
r.colors.stddev lsat8_2020.gvi
d.mon wx0
d.rast lsat8_2020.gvi
d.legend raster=lsat8_2020.gvi range=-1,0.7 title="GVI" title_fontsize=14 font="Helvetica" fontsize=12 -t -b bgcolor=white label_step=0.1 border_color=white thin=8 -d
d.out.file output=Nigeria_GVI_2020 format=jpg --overwrite
#
# 5. Calculation of DVI (Difference Vegetation Index)
g.region raster=lsat8_2020_toar.1 -p
i.vi blue=lsat8_2020_toar.2 red=lsat8_2020_toar.4 nir=lsat8_2020_toar.5 viname=dvi output=lsat8_2020.dvi --overwrite
r.colors lsat8_2020.dvi color=bgyr -e
# r.colors --help
d.mon wx0
d.rast lsat8_2020.dvi
d.legend raster=lsat8_2020.dvi range=-0.1,0.3 title="DVI" title_fontsize=14 font="Helvetica" fontsize=12 -t -b bgcolor=white label_step=0.02 border_color=white thin=8 -d
d.out.file output=Nigeria_DVI_2020 format=jpg --overwrite
#
# 6. Calculation of PVI (Perpendicular Vegetation Index)
g.region raster=lsat8_2020_toar.1 -p
i.vi red=lsat8_2020_toar.4 nir=lsat8_2020_toar.5 viname=pvi output=lsat8_2020.pvi --overwrite
#r.colors lsat8_2020.pvi color=byr -e
r.colors lsat8_2020.pvi color=bgyr -e
# r.colors --help
d.mon wx0
d.rast lsat8_2020.pvi
d.legend raster=lsat8_2020.pvi range=-0.1,0.3 title="PVI" title_fontsize=14 font="Helvetica" fontsize=12 -t -b bgcolor=white label_step=0.02 border_color=white thin=8 -d
d.out.file output=Nigeria_PVI_2020 format=jpg --overwrite

# 7. Calculation of GEMI: Global Environmental Monitoring Index
g.region raster=lsat8_2020_toar.1 -p
i.vi red=lsat8_2020_toar.4 nir=lsat8_2020_toar.5 viname=pvi output=lsat8_2020.pvi --overwrite
#r.colors lsat8_2020.pvi color=byr -e
r.colors lsat8_2020.pvi color=bcyr -e
# r.colors --help
d.mon wx0
d.rast lsat8_2020.pvi
d.legend raster=lsat8_2020.pvi range=-0.1,0.3 title="ARVI" title_fontsize=14 font="Helvetica" fontsize=12 -t -b bgcolor=white label_step=0.02 border_color=white thin=8 -d
d.out.file output=Nigeria_ARVI_2020 format=jpg --overwrite

#
# RGB colour composites
# False composite 5-4-3
r.composite blue=L8_2020_05 green=L8_2020_04 red=L8_2020_03 output=L8_2020_RGB --overwrite
# Natural colours 4-3-2
r.composite blue=L8_2020_02 green=L8_2020_03 red=L8_2020_04 output=L8_2020_RGB --overwrite
# visualizing the RGB triplet
d.mon wx0
g.region raster=L8_2020_RGB -p
gdalinfo LC08_L2SP_189056_20201220_20200912_02_T1_SR_B7.TIF
# r.colors --help
r.colors L8_2020_RGB col=grass
d.rast L8_2020_RGB

