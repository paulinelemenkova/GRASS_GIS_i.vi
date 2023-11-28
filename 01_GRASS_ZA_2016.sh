#!/bin/sh
# raster metadata:
r.info -r LC08_L2SP_189056_20161220_20200912_02_T1_SR_B1
# checking the selected random band
gdalinfo LC08_L2SP_189056_20161220_20200912_02_T1_SR_B7.TIF
# importing the image subset with 7 Landsat bands and display the raster map (polinalemenkova)
r.in.gdal /Users/polinalemenkova/grassdata/SouthAfrica_2016/LC08_L2SP_175083_20161023_20200906_02_T1_SR_B1.TIF out=L8_2016_01
r.in.gdal /Users/polinalemenkova/grassdata/SouthAfrica_2016/LC08_L2SP_175083_20161023_20200906_02_T1_SR_B2.TIF out=L8_2016_02
r.in.gdal /Users/polinalemenkova/grassdata/SouthAfrica_2016/LC08_L2SP_175083_20161023_20200906_02_T1_SR_B3.TIF out=L8_2016_03
r.in.gdal /Users/polinalemenkova/grassdata/SouthAfrica_2016/LC08_L2SP_175083_20161023_20200906_02_T1_SR_B4.TIF out=L8_2016_04
r.in.gdal /Users/polinalemenkova/grassdata/SouthAfrica_2016/LC08_L2SP_175083_20161023_20200906_02_T1_SR_B5.TIF out=L8_2016_05
r.in.gdal /Users/polinalemenkova/grassdata/SouthAfrica_2016/LC08_L2SP_175083_20161023_20200906_02_T1_SR_B6.TIF out=L8_2016_06
r.in.gdal /Users/polinalemenkova/grassdata/SouthAfrica_2016/LC08_L2SP_175083_20161023_20200906_02_T1_SR_B7.TIF out=L8_2016_07
r.in.gdal /Users/polinalemenkova/grassdata/SouthAfrica_2016/LC08_L2SP_175083_20161023_20200906_02_T1_ST_EMIS.TIF out=L8_2016_08
r.in.gdal /Users/polinalemenkova/grassdata/SouthAfrica_2016/LC08_L2SP_175083_20161023_20200906_02_T1_ST_EMSD.TIF out=L8_2016_09
r.in.gdal /Users/polinalemenkova/grassdata/SouthAfrica_2016/LC08_L2SP_175083_20161023_20200906_02_T1_ST_B10.TIF out=L8_2016_10
r.in.gdal /Users/polinalemenkova/grassdata/SouthAfrica_2016/LC08_L2SP_175083_20161023_20200906_02_T1_ST_TRAD.TIF out=L8_2016_11

# listing the files
g.list rast
# preprocessing:
# copying the Landsat bands to match the input structure of the i.landsat.toar
g.copy raster=L8_2016_01,lsat8_2016.1
g.copy raster=L8_2016_02,lsat8_2016.2
g.copy raster=L8_2016_03,lsat8_2016.3
g.copy raster=L8_2016_04,lsat8_2016.4
g.copy raster=L8_2016_05,lsat8_2016.5
g.copy raster=L8_2016_06,lsat8_2016.6
g.copy raster=L8_2016_07,lsat8_2016.7
g.copy raster=L8_2016_08,lsat8_2016.8
g.copy raster=L8_2016_09,lsat8_2016.9
g.copy raster=L8_2016_10,lsat8_2016.10
g.copy raster=L8_2016_11,lsat8_2016.11
# converting the DN pixel values to reflectance values using DOS1. From Digital Numer (DN) to reflectance. Before creating an RGB composite, it is important to convert the digital number data (DN) to reflectance (or optionally radiance). Otherwise the colors of a “natural” RGB composite do not look convincing but rather hazy (see background in the next screenshot). This conversion is done using the metadata file which is included in the data set with i.landsat.toar # i.landsat.toar - Calculates top-of-atmosphere radiance or reflectance and temperature for Landsat MSS/TM/ETM+/OLI
i.landsat.toar input=lsat8_2016. output=lsat8_2016_toar. sensor=oli8 \
    method=dos1 date=2016-10-23 sun_elevation=56.31386659 \
    product_date=2020-09-06 gain=HHHLHLHHL --overwrite
#
# 1. Calculation of DVI (Difference Vegetation Index)
g.region raster=lsat8_2016_toar.1 -p
i.vi blue=lsat8_2016_toar.2 red=lsat8_2016_toar.4 nir=lsat8_2016_toar.5 viname=dvi output=lsat8_2016.dvi --overwrite
r.colors lsat8_2016.dvi color=bcyr -e
# r.colors --help
d.mon wx0
d.rast lsat8_2016.dvi
d.legend raster=lsat8_2016.dvi range=-0.1,0.3 title="DVI-2016" title_fontsize=14 font="Helvetica" fontsize=12 -t -b bgcolor=white label_step=0.02 border_color=white thin=8 -d
d.out.file output=ZA_DVI_2016 format=jpg --overwrite
#
# 2. Calculation of SAVI: Soil Adjusted Vegetation Index
g.region raster=lsat8_2016_toar.1 -p
i.vi red=lsat8_2016_toar.4 nir=lsat8_2016_toar.5 viname=savi output=lsat8_2016.savi --overwrite
r.colors lsat8_2016.savi color=bgyr -e
# r.colors --help
d.mon wx0
d.rast lsat8_2016.savi
d.legend raster=lsat8_2016.savi range=-1.0,1.0 title="SAVI-2016" title_fontsize=14 font="Helvetica" fontsize=12 -t -b bgcolor=white label_step=0.2 border_color=white thin=8 -d
# d.erase
d.out.file output=ZA_SAVI_2016 format=jpg --overwrite
#
# 3. Calculation of NDVI
g.region raster=lsat8_2016_toar.4 -p
i.vi red=lsat8_2016_toar.4 nir=lsat8_2016_toar.5 viname=ndvi \
       output=lsat8_2016.ndvi --overwrite
r.colors lsat8_2016.ndvi color=gyr -e -n
# displaying the map
d.mon wx0
g.region raster=lsat8_2016_toar.4 -p
d.rast lsat8_2016.ndvi
d.legend raster=lsat8_2016.ndvi range=-1,1 title="NDVI-2016" title_fontsize=14 font=Helvetica fontsize=12 -t -s -b border_color=white thin=12 label_step=0.1 -d
d.out.file output=ZA_NDVI_2016 format=jpg --overwrite

# 4. Calculation of CI
g.region raster=lsat8_2016_toar.4 -p
i.vi blue=lsat8_2016_toar.2 red=lsat8_2016_toar.4 viname=ci \
       output=lsat8_2016.ci --overwrite
r.colors lsat8_2016.ci color=roygbiv -e
#-n
# displaying the map
d.mon wx0
g.region raster=lsat8_2016_toar.4 -p
d.rast lsat8_2016.ci
d.legend raster=lsat8_2016.ci range=-1,1 title="CI-2016" title_fontsize=14 font=Helvetica fontsize=12 -t -s -b border_color=white thin=12 label_step=0.1 -d
d.out.file output=ZA_CI_2016 format=jpg --overwrite
#
# 5. Calculation of ARVI
# ARVI = (nirchan - (2.0*redchan - bluechan)) / ( nirchan + (2.0*redchan - bluechan))
g.region raster=lsat8_2016_toar.3 -p
i.vi blue=lsat8_2016_toar.2 red=lsat8_2016_toar.4 nir=lsat8_2016_toar.5 \
       viname=arvi output=lsat8_2016.arvi --overwrite
r.colors lsat8_2016.arvi color=rainbow -e -n
# r.colors --help
d.mon wx0
d.rast lsat8_2016.arvi
d.legend raster=lsat8_2016.arvi range=-0.7,1.0 title="ARVI-2016" title_fontsize=14 font=Helvetica fontsize=12 -t -s -b border_color=white thin=12 label_step=0.1 -d
d.out.file output=Angola_ARVI_2016 format=jpg --overwrite
#
# 3. Calculation of GARI
# GARI = (nirchan - (2.0*redchan - bluechan)) / ( nirchan + (2.0*redchan - bluechan))
g.region raster=lsat8_2016_toar.3 -p
i.vi blue=lsat8_2016_toar.2 green=lsat8_2016_toar.3 red=lsat8_2016_toar.4 \
     nir=lsat8_2016_toar.5 viname=gari output=lsat8_2016.gari --overwrite
r.colors lsat8_2016.gari color=rainbow -e
# r.colors --help
d.mon wx0
d.rast lsat8_2016.gari
d.legend raster=lsat8_2016.gari range=-0.5,1.0 title="GARI-2013" title_fontsize=14 font="Helvetica" fontsize=12 -t -b bgcolor=white label_step=0.1 border_color=white thin=8 -d
d.out.file output=Angola_GARI_2016 format=jpg --overwrite
#
# 4. Calculation of GVI (Green Vegetation Index - Tasseled Cap)
g.region raster=lsat8_2016_toar.3 -p
i.vi blue=lsat8_2016_toar.2 green=lsat8_2016_toar.3 red=lsat8_2016_toar.4 nir=lsat8_2016_toar.5 band5=lsat8_2016_toar.6 band7=lsat8_2016_toar.7 viname=gvi output=lsat8_2016.gvi --overwrite
# r.colors --help
r.colors.stddev lsat8_2016.gvi
d.mon wx0
d.rast lsat8_2016.gvi
d.legend raster=lsat8_2016.gvi range=-1,0.7 title="GVI-2013" title_fontsize=14 font="Helvetica" fontsize=12 -t -b bgcolor=white label_step=0.1 border_color=white thin=8 -d
d.out.file output=Angola_GVI_2016 format=jpg --overwrite
#
# 6. Calculation of PVI (Perpendicular Vegetation Index)
g.region raster=lsat8_2016_toar.1 -p
i.vi red=lsat8_2016_toar.4 nir=lsat8_2016_toar.5 viname=pvi output=lsat8_2016.pvi --overwrite
r.colors lsat8_2016.pvi color=aspectcolr -e
# r.colors --help
d.mon wx0
d.rast lsat8_2016.pvi
d.legend raster=lsat8_2016.pvi range=-0.1,0.3 title="PVI-2013" title_fontsize=14 font="Helvetica" fontsize=12 -t -b bgcolor=white label_step=0.02 border_color=white thin=8 -d
d.out.file output=Angola_PVI_2016 format=jpg --overwrite
#
# 7. Calculation of GEMI: Global Environmental Monitoring Index
g.region raster=lsat8_2016_toar.1 -p
i.vi red=lsat8_2016_toar.4 nir=lsat8_2016_toar.5 viname=gemi output=lsat8_2016.gemi --overwrite
r.colors lsat8_2016.gemi color=rainbow -e -n
# r.colors --help
d.mon wx2
d.rast lsat8_2016.gemi
d.legend raster=lsat8_2016.gemi range=0.0,1.0 title="GEMI-2016" title_fontsize=14 font="Helvetica" fontsize=12 -t -b bgcolor=white label_step=0.1 border_color=white thin=8 -d
# d.erase
d.out.file output=ZA_GEMI_2016 format=jpg --overwrite
#
# 8. Calculation of NDWI: Normalized Difference Water Index
g.region raster=lsat8_2016_toar.1 -p
i.vi green=lsat8_2016_toar.3 nir=lsat8_2016_toar.5 viname=ndwi output=lsat8_2016.ndwi --overwrite
r.colors lsat8_2016.ndwi color=viridis -e
# r.colors --help
d.mon wx0
d.rast lsat8_2016.ndwi
d.legend raster=lsat8_2016.ndwi range=-1.0,0.5 title="NDWI-2013" title_fontsize=14 font="Helvetica" fontsize=12 -t -b bgcolor=white label_step=0.1 border_color=white thin=8 -d
# d.erase
d.out.file output=Angola_NDWI_2016 format=jpg --overwrite
#
# 10. Calculation of IPVI: Infrared Percentage Vegetation Index
g.region raster=lsat8_2016_toar.1 -p
i.vi red=lsat8_2016_toar.4 nir=lsat8_2016_toar.5 viname=ipvi output=lsat8_2016.ipvi --overwrite
r.colors lsat8_2016.ipvi color=haxby -e
# r.colors --help
d.mon wx0
d.rast lsat8_2016.ipvi
d.legend raster=lsat8_2016.ipvi range=-1.0,1.0 title="IPVI-2013" title_fontsize=14 font="Helvetica" fontsize=12 -t -b bgcolor=white label_step=0.1 border_color=white thin=8 -d
# d.erase
d.out.file output=Angola_IPVI_2016 format=jpg --overwrite
#
# 11. Calculation of EVI: Enhanced Vegetation Index
g.region raster=lsat8_2016_toar.1 -p
i.vi blue=lsat8_2016_toar.2 red=lsat8_2016_toar.4 nir=lsat8_2016_toar.5 viname=evi output=lsat8_2016.evi --overwrite
r.colors lsat8_2016.evi color=elevation -e
# r.colors --help
d.mon wx0
d.rast lsat8_2016.evi
d.legend raster=lsat8_2016.evi range=-1.0,1.0 title="EVI-2013" title_fontsize=14 font="Helvetica" fontsize=12 -t -b bgcolor=white label_step=0.1 border_color=white thin=8 -d
# d.erase
d.out.file output=Angola_EVI_2016 format=jpg --overwrite


# RGB colour composites
# False composite 5-4-3
r.composite blue=L8_2016_05 green=L8_2016_04 red=L8_2016_03 output=L8_2016_RGB --overwrite
r.composite blue=L8_2016_07 green=L8_2016_05 red=L8_2016_03 output=L8_2016_RGB --overwrite
# Natural colours 4-3-2
r.composite blue=L8_2016_02 green=L8_2016_03 red=L8_2016_04 output=L8_2016_RGB --overwrite
# visualizing the RGB triplet
d.mon wx0
g.region raster=L8_2016_RGB -p
gdalinfo LC08_L2SP_189056_20161220_20200912_02_T1_SR_B7.TIF
# r.colors --help
r.colors L8_2016_RGB col=grass
d.rast L8_2016_RGB
d.out.file output=ZA_2016_RGB format=jpg --overwrite

# RGB colour composites
# False composite 7-5-2
r.composite red=L8_2016_07 green=L8_2016_05 blue=L8_2016_02 output=L8_2016_RGB_752 --overwrite
# visualizing the RGB triplet
d.mon wx0
g.region raster=L8_2016_RGB_752 -p
#r.colors L8_2016_RGB_752 col=grass
d.rast L8_2016_RGB_752
d.out.file output=ZA_2016_RGB_752 format=jpg --overwrite


# False composite 5-4-3 (NIR, Red, Green)
r.composite red=L8_2016_05 green=L8_2016_04 blue=L8_2016_03 output=L8_2016_RGB_543 --overwrite
# visualizing the RGB triplet
d.mon wx0
g.region raster=L8_2016_RGB_543 -p
#r.colors L8_2016_RGB_752 col=grass
d.rast L8_2016_RGB_543
d.out.file output=ZA_2016_RGB_543 format=jpg --overwrite

