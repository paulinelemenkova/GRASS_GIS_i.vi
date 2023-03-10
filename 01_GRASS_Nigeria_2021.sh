#!/bin/sh
# raster metadata:
r.info -r LC08_L2SP_189056_20211220_20200912_02_T1_SR_B1
# checking the selected random band
gdalinfo LC08_L2SP_189056_20211220_20200912_02_T1_SR_B7.TIF
# importing the image subset with 7 Landsat bands and display the raster map (polinalemenkova)
r.in.gdal LC09_L2SP_189056_20211218_20220121_02_T1_SR_B1.TIF out=L8_2021_01
r.in.gdal LC09_L2SP_189056_20211218_20220121_02_T1_SR_B2.TIF out=L8_2021_02
r.in.gdal LC09_L2SP_189056_20211218_20220121_02_T1_SR_B3.TIF out=L8_2021_03
r.in.gdal LC09_L2SP_189056_20211218_20220121_02_T1_SR_B4.TIF out=L8_2021_04
r.in.gdal LC09_L2SP_189056_20211218_20220121_02_T1_SR_B5.TIF out=L8_2021_05
r.in.gdal LC09_L2SP_189056_20211218_20220121_02_T1_SR_B6.TIF out=L8_2021_06
r.in.gdal LC09_L2SP_189056_20211218_20220121_02_T1_SR_B7.TIF out=L8_2021_07
r.in.gdal LC09_L2SP_189056_20211218_20220121_02_T1_ST_EMIS.TIF out=L8_2021_08
r.in.gdal LC09_L2SP_189056_20211218_20220121_02_T1_ST_EMSD.TIF out=L8_2021_09
r.in.gdal LC09_L2SP_189056_20211218_20220121_02_T1_ST_B10.TIF out=L8_2021_10
r.in.gdal LC09_L2SP_189056_20211218_20220121_02_T1_ST_TRAD.TIF out=L8_2021_11

# listing the files
g.list rast
# preprocessing:
# copying the Landsat bands to match the input structure of the i.landsat.toar
g.copy raster=L8_2021_01,lsat8_2021.1
g.copy raster=L8_2021_02,lsat8_2021.2
g.copy raster=L8_2021_03,lsat8_2021.3
g.copy raster=L8_2021_04,lsat8_2021.4
g.copy raster=L8_2021_05,lsat8_2021.5
g.copy raster=L8_2021_06,lsat8_2021.6
g.copy raster=L8_2021_07,lsat8_2021.7
g.copy raster=L8_2021_08,lsat8_2021.8
g.copy raster=L8_2021_09,lsat8_2021.9
g.copy raster=L8_2021_10,lsat8_2021.10
g.copy raster=L8_2021_11,lsat8_2021.11
# converting the DN pixel values to reflectance values using DOS1. From Digital Numer (DN) to reflectance. Before creating an RGB composite, it is important to convert the digital number data (DN) to reflectance (or optionally radiance). Otherwise the colors of a “natural” RGB composite do not look convincing but rather hazy (see background in the next screenshot). This conversion is done using the metadata file which is included in the data set with i.landsat.toar # i.landsat.toar - Calculates top-of-atmosphere radiance or reflectance and temperature for Landsat MSS/TM/ETM+/OLI
i.landsat.toar input=lsat8_2021. output=lsat8_2021_toar. sensor=oli8 \
    method=dos1 date=2021-12-18 sun_elevation=51.85111023 \
    product_date=2021-12-18 gain=HHHLHLHHL
#
# Calculation of VI
#
# 1. Calculation of NDVI
g.region raster=lsat8_2021_toar.4 -p
i.vi red=lsat8_2021_toar.4 nir=lsat8_2021_toar.5 viname=ndvi \
       output=lsat8_2021.ndvi --overwrite
r.colors lsat8_2021.ndvi color=ndvi
# displaying the map
d.mon wx0
g.region raster=lsat8_2021_toar.4 -p
d.rast lsat8_2021.ndvi
d.legend raster=lsat8_2021.ndvi range=-1,1 title="NDVI" title_fontsize=14 font=Helvetica fontsize=12 -t -s -b border_color=white thin=12 label_step=0.1 -d
d.out.file output=Nigeria_NDVI_2021 format=jpg --overwrite
#
# 2. Calculation of ARVI
# ARVI = (nirchan - (2.0*redchan - bluechan)) / ( nirchan + (2.0*redchan - bluechan))
g.region raster=lsat8_2021_toar.3 -p
i.vi blue=lsat8_2021_toar.2 red=lsat8_2021_toar.4 nir=lsat8_2021_toar.5 \
       viname=arvi output=lsat8_2021.arvi --overwrite
r.colors lsat8_2021.arvi color=bcyr -e
# r.colors --help
d.mon wx0
d.rast lsat8_2021.arvi
d.legend raster=lsat8_2021.arvi range=-0.7,1.0 title="ARVI" title_fontsize=14 font=Helvetica fontsize=12 -t -s -b border_color=white thin=12 label_step=0.1 -d
d.out.file output=Nigeria_ARVI_2021 format=jpg --overwrite
#
# 3. Calculation of GARI
# GARI = (nirchan - (2.0*redchan - bluechan)) / ( nirchan + (2.0*redchan - bluechan))
g.region raster=lsat8_2021_toar.3 -p
i.vi blue=lsat8_2021_toar.2 green=lsat8_2021_toar.3 red=lsat8_2021_toar.4 \
     nir=lsat8_2021_toar.5 viname=gari output=lsat8_2021.gari --overwrite
r.colors lsat8_2021.gari color=rainbow -e
# r.colors --help
d.mon wx1
d.rast lsat8_2021.gari
d.legend raster=lsat8_2021.gari range=-0.5,1.0 title="GARI" title_fontsize=14 font="Helvetica" fontsize=12 -t -b bgcolor=white label_step=0.1 border_color=white thin=8 -d
d.out.file output=Nigeria_GARI_2021 format=jpg --overwrite
#
# 4. Calculation of GVI (Green Vegetation Index - Tasseled Cap)
g.region raster=lsat8_2021_toar.3 -p
i.vi blue=lsat8_2021_toar.2 green=lsat8_2021_toar.3 red=lsat8_2021_toar.4 nir=lsat8_2021_toar.5 band5=lsat8_2021_toar.6 band7=lsat8_2021_toar.7 viname=gvi output=lsat8_2021.gvi --overwrite
# r.colors --help
r.colors.stddev lsat8_2021.gvi
d.mon wx0
d.rast lsat8_2021.gvi
d.legend raster=lsat8_2021.gvi range=-1,0.7 title="GVI" title_fontsize=14 font="Helvetica" fontsize=12 -t -b bgcolor=white label_step=0.1 border_color=white thin=8 -d
d.out.file output=Nigeria_GVI_2021 format=jpg --overwrite
#
# 5. Calculation of DVI (Difference Vegetation Index)
g.region raster=lsat8_2021_toar.1 -p
i.vi blue=lsat8_2021_toar.2 red=lsat8_2021_toar.4 nir=lsat8_2021_toar.5 viname=dvi output=lsat8_2021.dvi --overwrite
r.colors lsat8_2021.dvi color=bgyr -e
# r.colors --help
d.mon wx0
d.rast lsat8_2021.dvi
d.legend raster=lsat8_2021.dvi range=-0.1,0.3 title="DVI" title_fontsize=14 font="Helvetica" fontsize=12 -t -b bgcolor=white label_step=0.02 border_color=white thin=8 -d
d.out.file output=Nigeria_DVI_2021 format=jpg --overwrite
#
# 6. Calculation of PVI (Perpendicular Vegetation Index)
g.region raster=lsat8_2021_toar.1 -p
i.vi red=lsat8_2021_toar.4 nir=lsat8_2021_toar.5 viname=pvi output=lsat8_2021.pvi --overwrite
r.colors lsat8_2021.pvi color=byr -e
# r.colors --help
d.mon wx0
d.rast lsat8_2021.pvi
d.legend raster=lsat8_2021.pvi range=-0.1,0.3 title="PVI" title_fontsize=14 font="Helvetica" fontsize=12 -t -b bgcolor=white label_step=0.02 border_color=white thin=8 -d
d.out.file output=Nigeria_PVI_2021 format=jpg --overwrite

# 7. Calculation of GEMI: Global Environmental Monitoring Index
g.region raster=lsat8_2021_toar.1 -p
i.vi red=lsat8_2021_toar.4 nir=lsat8_2021_toar.5 viname=gemi output=lsat8_2021.gemi --overwrite
r.colors lsat8_2021.gemi color=roygbiv -e
# r.colors --help
d.mon wx0
d.rast lsat8_2021.gemi
d.legend raster=lsat8_2021.gemi range=-0.5,1.0 title="GEMI" title_fontsize=14 font="Helvetica" fontsize=12 -t -b bgcolor=white label_step=0.1 border_color=white thin=8 -d
# d.erase
d.out.file output=Nigeria_GEMI_2021 format=jpg --overwrite

# 8. Calculation of NDWI: Normalized Difference Water Index
g.region raster=lsat8_2021_toar.1 -p
i.vi green=lsat8_2021_toar.3 nir=lsat8_2021_toar.5 viname=ndwi output=lsat8_2021.ndwi --overwrite
r.colors lsat8_2021.ndwi color=viridis -e
# r.colors --help
d.mon wx0
d.rast lsat8_2021.ndwi
d.legend raster=lsat8_2021.ndwi range=-1.0,0.5 title="NDWI" title_fontsize=14 font="Helvetica" fontsize=12 -t -b bgcolor=white label_step=0.1 border_color=white thin=8 -d
# d.erase
d.out.file output=Nigeria_NDWI_2021 format=jpg --overwrite
#
# 9. Calculation of MSAVI2: second Modified Soil Adjusted Vegetation Index
g.region raster=lsat8_2021_toar.1 -p
i.vi red=lsat8_2021_toar.4 nir=lsat8_2021_toar.5 viname=msavi2 output=lsat8_2021.msavi2 --overwrite
r.colors lsat8_2021.msavi2 color=soilmoisture -e
# r.colors --help
d.mon wx0
d.rast lsat8_2021.msavi2
d.legend raster=lsat8_2021.msavi2 range=-1.0,0.5 title="MSAVI2" title_fontsize=14 font="Helvetica" fontsize=12 -t -b bgcolor=white label_step=0.1 border_color=white thin=8 -d
# d.erase
d.out.file output=Nigeria_MSAVI2_2021 format=jpg --overwrite
#
# 10. Calculation of IPVI: Infrared Percentage Vegetation Index
g.region raster=lsat8_2021_toar.1 -p
i.vi red=lsat8_2021_toar.4 nir=lsat8_2021_toar.5 viname=ipvi output=lsat8_2021.ipvi --overwrite
r.colors lsat8_2021.ipvi color=haxby -e
# r.colors --help
d.mon wx0
d.rast lsat8_2021.ipvi
d.legend raster=lsat8_2021.ipvi range=-1.0,1.0 title="IPVI" title_fontsize=14 font="Helvetica" fontsize=12 -t -b bgcolor=white label_step=0.1 border_color=white thin=8 -d
# d.erase
d.out.file output=Nigeria_IPVI_2021 format=jpg --overwrite
#
# 11. Calculation of EVI: Enhanced Vegetation Index
g.region raster=lsat8_2021_toar.1 -p
i.vi blue=lsat8_2021_toar.2 red=lsat8_2021_toar.4 nir=lsat8_2021_toar.5 viname=evi output=lsat8_2021.evi --overwrite
r.colors lsat8_2021.evi color=elevation -e
# r.colors --help
d.mon wx0
d.rast lsat8_2021.evi
d.legend raster=lsat8_2021.evi range=-1.0,1.0 title="EVI" title_fontsize=14 font="Helvetica" fontsize=12 -t -b bgcolor=white label_step=0.1 border_color=white thin=8 -d
# d.erase
d.out.file output=Nigeria_EVI_2021 format=jpg --overwrite

# RGB colour composites
# False composite 5-4-3
r.composite blue=L8_2021_05 green=L8_2021_04 red=L8_2021_03 output=L8_2021_RGB --overwrite
# Natural colours 4-3-2
r.composite blue=L8_2021_02 green=L8_2021_03 red=L8_2021_04 output=L8_2021_RGB --overwrite
# visualizing the RGB triplet
d.mon wx0
g.region raster=L8_2021_RGB -p
gdalinfo LC08_L2SP_189056_20211220_20200912_02_T1_SR_B7.TIF
# r.colors --help
r.colors L8_2021_RGB col=grass
d.rast L8_2021_RGB

