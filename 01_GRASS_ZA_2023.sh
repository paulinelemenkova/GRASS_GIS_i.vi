#!/bin/sh
# raster metadata:
r.info -r LC08_L2SP_189056_20231220_20200912_02_T1_SR_B1
# checking the selected random band
gdalinfo LC08_L2SP_189056_20231220_20200912_02_T1_SR_B7.TIF
# importing the image subset with 7 Landsat bands and display the raster map (polinalemenkova)
r.in.gdal /Users/polinalemenkova/grassdata/SouthAfrica_2023/LC09_L2SP_175083_20231019_20231020_02_T1_SR_B1.TIF out=L8_2023_01
r.in.gdal /Users/polinalemenkova/grassdata/SouthAfrica_2023/LC09_L2SP_175083_20231019_20231020_02_T1_SR_B2.TIF out=L8_2023_02
r.in.gdal /Users/polinalemenkova/grassdata/SouthAfrica_2023/LC09_L2SP_175083_20231019_20231020_02_T1_SR_B3.TIF out=L8_2023_03
r.in.gdal /Users/polinalemenkova/grassdata/SouthAfrica_2023/LC09_L2SP_175083_20231019_20231020_02_T1_SR_B4.TIF out=L8_2023_04
r.in.gdal /Users/polinalemenkova/grassdata/SouthAfrica_2023/LC09_L2SP_175083_20231019_20231020_02_T1_SR_B5.TIF out=L8_2023_05
r.in.gdal /Users/polinalemenkova/grassdata/SouthAfrica_2023/LC09_L2SP_175083_20231019_20231020_02_T1_SR_B6.TIF out=L8_2023_06
r.in.gdal /Users/polinalemenkova/grassdata/SouthAfrica_2023/LC09_L2SP_175083_20231019_20231020_02_T1_SR_B7.TIF out=L8_2023_07
r.in.gdal /Users/polinalemenkova/grassdata/SouthAfrica_2023/LC09_L2SP_175083_20231019_20231020_02_T1_ST_EMIS.TIF out=L8_2023_08
r.in.gdal /Users/polinalemenkova/grassdata/SouthAfrica_2023/LC09_L2SP_175083_20231019_20231020_02_T1_ST_EMSD.TIF out=L8_2023_09
r.in.gdal /Users/polinalemenkova/grassdata/SouthAfrica_2023/LC09_L2SP_175083_20231019_20231020_02_T1_SR_B10.TIF out=L8_2023_10
r.in.gdal /Users/polinalemenkova/grassdata/SouthAfrica_2023/LC09_L2SP_175083_20231019_20231020_02_T1_ST_TRAD.TIF out=L8_2023_11

# listing the files
g.list rast
# preprocessing:
# copying the Landsat bands to match the input structure of the i.landsat.toar
g.copy raster=L8_2023_01,lsat8_2023.1
g.copy raster=L8_2023_02,lsat8_2023.2
g.copy raster=L8_2023_03,lsat8_2023.3
g.copy raster=L8_2023_04,lsat8_2023.4
g.copy raster=L8_2023_05,lsat8_2023.5
g.copy raster=L8_2023_06,lsat8_2023.6
g.copy raster=L8_2023_07,lsat8_2023.7
g.copy raster=L8_2023_08,lsat8_2023.8
g.copy raster=L8_2023_09,lsat8_2023.9
g.copy raster=L8_2023_10,lsat8_2023.10
g.copy raster=L8_2023_11,lsat8_2023.11
# converting the DN pixel values to reflectance values using DOS1. From Digital Numer (DN) to reflectance. Before creating an RGB composite, it is important to convert the digital number data (DN) to reflectance (or optionally radiance). Otherwise the colors of a “natural” RGB composite do not look convincing but rather hazy (see background in the next screenshot). This conversion is done using the metadata file which is included in the data set with i.landsat.toar # i.landsat.toar - Calculates top-of-atmosphere radiance or reflectance and temperature for Landsat MSS/TM/ETM+/OLI
i.landsat.toar input=lsat8_2023. output=lsat8_2023_toar. sensor=oli8 \
    method=dos1 date=2023-10-19 sun_elevation=54.96134606 \
    product_date=2023-10-20 gain=HHHLHLHHL --overwrite
#
# 1. Calculation of DVI (Difference Vegetation Index)
g.region raster=lsat8_2023_toar.1 -p
i.vi blue=lsat8_2023_toar.2 red=lsat8_2023_toar.4 nir=lsat8_2023_toar.5 viname=dvi output=lsat8_2023.dvi --overwrite
r.colors lsat8_2023.dvi color=bcyr -e
# r.colors --help
d.mon wx0
d.rast lsat8_2023.dvi
d.legend raster=lsat8_2023.dvi range=-0.1,0.3 title="DVI-2023" title_fontsize=14 font="Helvetica" fontsize=12 -t -b bgcolor=white label_step=0.02 border_color=white thin=8 -d
d.out.file output=ZA_DVI_2023 format=jpg --overwrite
#
# 2. Calculation of SAVI: Soil Adjusted Vegetation Index
g.region raster=lsat8_2023_toar.1 -p
i.vi red=lsat8_2023_toar.4 nir=lsat8_2023_toar.5 viname=savi output=lsat8_2023.savi --overwrite
r.colors lsat8_2023.savi color=bgyr -e
# r.colors --help
d.mon wx0
d.rast lsat8_2023.savi
d.legend raster=lsat8_2023.savi range=-1.0,1.0 title="SAVI-2023" title_fontsize=14 font="Helvetica" fontsize=12 -t -b bgcolor=white label_step=0.2 border_color=white thin=8 -d
# d.erase
d.out.file output=ZA_SAVI_2023 format=jpg --overwrite
#
# 3. Calculation of NDVI
g.region raster=lsat8_2023_toar.4 -p
i.vi red=lsat8_2023_toar.4 nir=lsat8_2023_toar.5 viname=ndvi \
       output=lsat8_2023.ndvi --overwrite
r.colors lsat8_2023.ndvi color=gyr -e -n
# displaying the map
d.mon wx0
g.region raster=lsat8_2023_toar.4 -p
d.rast lsat8_2023.ndvi
d.legend raster=lsat8_2023.ndvi range=-1,1 title="NDVI-2023" title_fontsize=14 font=Helvetica fontsize=12 -t -s -b border_color=white thin=12 label_step=0.1 -d
d.out.file output=ZA_NDVI_2023 format=jpg --overwrite

# 4. Calculation of CI
g.region raster=lsat8_2023_toar.4 -p
i.vi blue=lsat8_2023_toar.2 red=lsat8_2023_toar.4 viname=ci \
       output=lsat8_2023.ci --overwrite
r.colors lsat8_2023.ci color=roygbiv -e
#-n
# displaying the map
d.mon wx0
g.region raster=lsat8_2023_toar.4 -p
d.rast lsat8_2023.ci
d.legend raster=lsat8_2023.ci range=-1,1 title="CI-2023" title_fontsize=14 font=Helvetica fontsize=12 -t -s -b border_color=white thin=12 label_step=0.1 -d
d.out.file output=ZA_CI_2023 format=jpg --overwrite
#
# 5. Calculation of GEMI: Global Environmental Monitoring Index
g.region raster=lsat8_2023_toar.1 -p
i.vi red=lsat8_2023_toar.4 nir=lsat8_2023_toar.5 viname=gemi output=lsat8_2023.gemi --overwrite
r.colors lsat8_2023.gemi color=rainbow -e -n
# r.colors --help
d.mon wx0
d.rast lsat8_2023.gemi
d.legend raster=lsat8_2023.gemi range=0.0,1.0 title="GEMI-2023" title_fontsize=14 font="Helvetica" fontsize=12 -t -b bgcolor=white label_step=0.1 border_color=white thin=8 -d
# d.erase
d.out.file output=ZA_GEMI_2023 format=jpg --overwrite



g.region raster=lsat8_2023_toar.1 -p
i.vi red=lsat8_2023_toar.4 nir=lsat8_2023_toar.5 viname=gemi output=lsat8_2023.gemi --overwrite
r.colors lsat8_2023.gemi color=rainbow -e -n
# r.colors --help
d.mon wx0
d.rast lsat8_2023.gemi
d.legend raster=lsat8_2023.gemi range=-1.0,1.0 title="GEMI-2023" title_fontsize=14 font="Helvetica" fontsize=12 -t -b bgcolor=white label_step=0.1 border_color=white thin=8 -d
# d.erase
d.out.file output=ZA_GEMI_2023 format=jpg --overwrite
