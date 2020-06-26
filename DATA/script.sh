#!/bin/bash
base_dir="./RAW/dpsg2020-06-00359/ddExt/RGEALTI/1_DONNEES_LIVRAISON_2020-06-00359/RGEALTI_MNT_1M_ASC_LAMB93_IGN69_RTTK-G4T7_20200623/"
processed_dir="./PROCESSED/"
echo "Build VRT"
gdalbuildvrt "${processed_dir}"output.vrt -overwrite "${base_dir}"*.asc
echo "Convert to GTiff"
gdal_translate -of GTiff "${processed_dir}"output.vrt "${processed_dir}"output.tiff
echo "Warp to WGS84"
gdalwarp -overwrite -s_srs EPSG:2154 -t_srs EPSG:4326 -tr 0.00001 -0.00001 "${processed_dir}"output.tiff "${processed_dir}"output_4326.tiff


#GeoConvert -g -w -p 4 --input-string "45:45:00N 06:07:00E"
#GeoConvert -g -w -p 4 --input-string "45:57:00N 06:12:00E"

#GeoConvert -g -w -p 4 --input-string "45:59:00N 06:18:00E"
#GeoConvert -g -w -p 4 --input-string "46:03:00N 06:26:00E"

#bl="45:53N 6:10E"
#tr="45:54N 6:11E"
#south="45:53:00N"
#west="6:10:00E"
#north="45:54:00N"
#east="6:11:00E"

#Zone 1
#south="45:45:00N" #11
#west="6:07:00E" #4

#Zone 2
south="45:59:00N" #3
west="6:18:00E" #7

# north axis
for y in {0..3}; do
    ybl="+0:${y}:0";
    ytr="+0:$((y+1)):0";
    # east axis
    for x in {0..7}; do
       xbl="+0:${x}:0";
       xtr="+0:$((x+1)):0";
       bl=$(GeoConvert -g -p 4 -w --input-string "${south}${ybl} ${west}${xbl}")
       tr=$(GeoConvert -g -p 4 -w --input-string "${south}${ytr} ${west}${xtr}")
       bbox=${bl}" "${tr}
       bbox_str=$(echo ${bl}"_"${tr} | sed "s/ /_/g")
       echo "Tiling bbox: ${bbox}..."
       echo "${processed_dir}"output_4326_"${bbox_str}".tiff
       gdalwarp -overwrite -te ${bbox} -tr 0.00001 -0.00001 "${processed_dir}"output_4326.tiff "${processed_dir}"output_4326_"${bbox_str}".tiff
    done
done

#echo "Tiling..."
#gdalwarp -overwrite -te ${bbox} "${processed_dir}"output_4326.tiff "${processed_dir}"output_4326_1.tiff



