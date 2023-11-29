#!/bin/sh
# raster metadata:
r.info -r LC08_L2SP_189056_20211220_20200912_02_T1_SR_B1
# checking the selected random band
gdalinfo LC08_L2SP_189056_20211220_20200912_02_T1_SR_B7.TIF
# importing the image subset with 7 Landsat bands and display the raster map (polinalemenkova)
r.in.gdal /Users/polinalemenkova/grassdata/SouthAfrica_2021/LC08_L2SP_175083_20211005_20211013_02_T1_SR_B1.TIF out=L8_2021_01
r.in.gdal /Users/polinalemenkova/grassdata/SouthAfrica_2021/LC08_L2SP_175083_20211005_20211013_02_T1_SR_B2.TIF out=L8_2021_02
r.in.gdal /Users/polinalemenkova/grassdata/SouthAfrica_2021/LC08_L2SP_175083_20211005_20211013_02_T1_SR_B3.TIF out=L8_2021_03
r.in.gdal /Users/polinalemenkova/grassdata/SouthAfrica_2021/LC08_L2SP_175083_20211005_20211013_02_T1_SR_B4.TIF out=L8_2021_04
r.in.gdal /Users/polinalemenkova/grassdata/SouthAfrica_2021/LC08_L2SP_175083_20211005_20211013_02_T1_SR_B5.TIF out=L8_2021_05
r.in.gdal /Users/polinalemenkova/grassdata/SouthAfrica_2021/LC08_L2SP_175083_20211005_20211013_02_T1_SR_B6.TIF out=L8_2021_06
r.in.gdal /Users/polinalemenkova/grassdata/SouthAfrica_2021/LC08_L2SP_175083_20211005_20211013_02_T1_SR_B7.TIF out=L8_2021_07
r.in.gdal /Users/polinalemenkova/grassdata/SouthAfrica_2021/LC08_L2SP_175083_20211005_20211013_02_T1_ST_EMIS.TIF out=L8_2021_08
r.in.gdal /Users/polinalemenkova/grassdata/SouthAfrica_2021/LC08_L2SP_175083_20211005_20211013_02_T1_ST_EMSD.TIF out=L8_2021_09
r.in.gdal /Users/polinalemenkova/grassdata/SouthAfrica_2021/LC08_L2SP_175083_20211005_20211013_02_T1_ST_B10.TIF out=L8_2021_10
r.in.gdal /Users/polinalemenkova/grassdata/SouthAfrica_2021/LC08_L2SP_175083_20211005_20211013_02_T1_ST_TRAD.TIF out=L8_2021_11

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
    method=dos1 date=2021-10-05 sun_elevation=50.69397690 \
    product_date=2021-10-13 gain=HHHLHLHHL --overwrite
#
# 1. Calculation of DVI (Difference Vegetation Index)
g.region raster=lsat8_2021_toar.1 -p
i.vi blue=lsat8_2021_toar.2 red=lsat8_2021_toar.4 nir=lsat8_2021_toar.5 viname=dvi output=lsat8_2021.dvi --overwrite
r.colors lsat8_2021.dvi color=bcyr -e
# r.colors --help
d.mon wx0
d.rast lsat8_2021.dvi
d.legend raster=lsat8_2021.dvi range=-0.1,0.3 title="DVI-2021" title_fontsize=14 font="Helvetica" fontsize=12 -t -b bgcolor=white label_step=0.02 border_color=white thin=8 -d
d.out.file output=ZA_DVI_2021 format=jpg --overwrite
#
# 2. Calculation of SAVI: Soil Adjusted Vegetation Index
g.region raster=lsat8_2021_toar.1 -p
i.vi red=lsat8_2021_toar.4 nir=lsat8_2021_toar.5 viname=savi output=lsat8_2021.savi --overwrite
r.colors lsat8_2021.savi color=bgyr -e
# r.colors --help
d.mon wx0
d.rast lsat8_2021.savi
d.legend raster=lsat8_2021.savi range=-1.0,1.0 title="SAVI-2021" title_fontsize=14 font="Helvetica" fontsize=12 -t -b bgcolor=white label_step=0.2 border_color=white thin=8 -d
# d.erase
d.out.file output=ZA_SAVI_2021 format=jpg --overwrite
#
# 3. Calculation of NDVI
g.region raster=lsat8_2021_toar.4 -p
i.vi red=lsat8_2021_toar.4 nir=lsat8_2021_toar.5 viname=ndvi \
       output=lsat8_2021.ndvi --overwrite
r.colors lsat8_2021.ndvi color=gyr -e -n
# displaying the map
d.mon wx0
g.region raster=lsat8_2021_toar.4 -p
d.rast lsat8_2021.ndvi
d.legend raster=lsat8_2021.ndvi range=-1,1 title="NDVI-2021" title_fontsize=14 font=Helvetica fontsize=12 -t -s -b border_color=white thin=12 label_step=0.1 -d
d.out.file output=ZA_NDVI_2021 format=jpg --overwrite

# 4. Calculation of CI
g.region raster=lsat8_2021_toar.4 -p
i.vi blue=lsat8_2021_toar.2 red=lsat8_2021_toar.4 viname=ci \
       output=lsat8_2021.ci --overwrite
r.colors lsat8_2021.ci color=roygbiv -e
#-n
# displaying the map
d.mon wx0
g.region raster=lsat8_2021_toar.4 -p
d.rast lsat8_2021.ci
d.legend raster=lsat8_2021.ci range=-1,1 title="CI-2021" title_fontsize=14 font=Helvetica fontsize=12 -t -s -b border_color=white thin=12 label_step=0.1 -d
d.out.file output=ZA_CI_2021 format=jpg --overwrite
#
# 5. Calculation of GEMI: Global Environmental Monitoring Index
g.region raster=lsat8_2021_toar.1 -p
i.vi red=lsat8_2021_toar.4 nir=lsat8_2021_toar.5 viname=gemi output=lsat8_2021.gemi --overwrite
r.colors lsat8_2021.gemi color=rainbow -e -n
# r.colors --help
d.mon wx0
d.rast lsat8_2021.gemi
d.legend raster=lsat8_2021.gemi range=0.0,1.0 title="GEMI-2021" title_fontsize=14 font="Helvetica" fontsize=12 -t -b bgcolor=white label_step=0.1 border_color=white thin=8 -d
# d.erase
d.out.file output=ZA_GEMI_2021 format=jpg --overwrite
