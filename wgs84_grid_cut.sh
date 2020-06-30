#!/bin/bash

data_dir1=$(pwd)"/DATA/RAW/dpsg2020-06-00359/ddExt/RGEALTI/1_DONNEES_LIVRAISON_2020-06-00359/RGEALTI_MNT_1M_ASC_LAMB93_IGN69_RTTK-G4T7_20200623/"
data_dir2=$(pwd)"/DATA/RAW/dpsg2020-06-00483/ddExt/RGEALTI/1_DONNEES_LIVRAISON_2020-06-00483/RGEALTI_MNT_1M_ASC_LAMB93_IGN69_6N3B-SUHX_20200630/"

processed_dir=$(pwd)"/DATA/PROCESSED/"

if [ $# -eq 0 ]
then
    compute_base=${COMPUTE_BASE}

    > ${processed_dir}input_files;
    > ${processed_dir}output.vrt;
    find ${data_dir1} -type f -iname *.asc > ${processed_dir}input_files;
    find ${data_dir2} -type f -iname *.asc >> ${processed_dir}input_files;

    if [ ${compute_base} = 'true' ]
    then
        echo "Build VRT"
        gdalbuildvrt "${processed_dir}"output.vrt -overwrite -input_file_list ${processed_dir}input_files; #"${data_dir1}"*.asc
        echo "Convert to GTiff"
        gdal_translate -of GTiff "${processed_dir}"output.vrt "${processed_dir}"output.tiff
        echo "Warp to WGS84"
        gdalwarp -overwrite -s_srs EPSG:2154 -t_srs EPSG:4326 -tr 0.00001 -0.00001 "${processed_dir}"output.tiff "${processed_dir}"output_4326.tiff
    fi
fi

## Zone 1
#GeoConvert -g -w -p 4 --input-string "45:45:00N 06:07:00E" # south west
#GeoConvert -g -w -p 4 --input-string "45:57:00N 06:12:00E" # north east

## Zone 2
#GeoConvert -g -w -p 4 --input-string "45:59:00N 06:18:00E" # south west
#GeoConvert -g -w -p 4 --input-string "46:03:00N 06:26:00E" # north east

#bl="45:53N 6:10E"
#tr="45:54N 6:11E"
#south="45:53:00N"
#west="6:10:00E"
#north="45:54:00N"
#east="6:11:00E"
if [ $# -ne 1 ]
then
    echo "Please, give the area number as an argument."
else
    if [ ${1} = "1" ]
    then
        #Zone 1
        zone_dir="${processed_dir}ZONE${1}/"
        north="45:57:00N" #11
        south="45:45:00N" #11
        west="6:07:00E" #4
        east="6:12:00E" #4
    elif [ ${1} = "2" ]
    then
        #Zone 2
        zone_dir="${processed_dir}ZONE${1}/"
        north="46:03:00N" #3
        south="45:59:00N" #3
        west="6:18:00E" #7
        east="6:26:00E" #7
    else
        echo "Wrong area!"
    fi

    echo "Processing zone ${1}..."
    rm -rf ${processed_dir}ZONE${1}/*.tiff;
    rm -rf ${processed_dir}ZONE${1}/OBJ/*.obj;
    mkdir -p ${zone_dir}

    #Computing decimal coordinates of the 4 bbox corners:
    tl_bbox=$(GeoConvert -g -w -p 4 --input-string "${north} ${west}")
    tr_bbox=$(GeoConvert -g -w -p 4 --input-string "${north} ${east}")
    bl_bbox=$(GeoConvert -g -w -p 4 --input-string "${south} ${west}")
    br_bbox=$(GeoConvert -g -w -p 4 --input-string "${south} ${east}")

    # Computing chunks:
    IFS=' '
    deltas=$(GeoConvert -g -p 4 -w --input-string "${north}-${south} ${east}-${west}")
    read -r -a array <<< "${deltas}"
    dWE=${array[0]}
    dSN=${array[1]}
    echo "deltas: ${dWE} ${DSN}"
    x_step_max=$(printf "%1.f\n" $(bc -l <<< "60 * ${dWE} - 1"))
    y_step_max=$(printf "%1.f\n" $(bc -l <<< "60 * ${dSN} - 1"))

    # north axis
    for (( y=0; y<=${y_step_max}; y++ )); do 
        ybl="+0:${y}:0"; #
        ytr="+0:$((y+1)):0"; #
        # east axis
        for (( x=0; x<=${x_step_max}; x++ )); do 
            xbl="+0:${x}:0"; #
            xtr="+0:$((x+1)):0"; #
            bl=$(GeoConvert -g -p 4 -w --input-string "${south}${ybl} ${west}${xbl}") #
            tr=$(GeoConvert -g -p 4 -w --input-string "${south}${ytr} ${west}${xtr}") #
            tl=$(GeoConvert -g -p 4 -w --input-string "${south}${ytr} ${west}${xbl}")
            br=$(GeoConvert -g -p 4 -w --input-string "${south}${ybl} ${west}${xtr}")
            bbox=${bl}" "${tr}
            bbox_str=$(echo ${bl}"_"${tr} | sed "s/ /_/g")
            bbox_str2=$(echo ${tl}"_"${br} | sed "s/ /_/g")
            tl_dms=$(GeoConvert -: -p -1 -w --input-string "${tl}")
            bbox_str3=$(echo ${tl_dms} | sed "s/ /_/g" | sed "s/:/\./g")
            echo "Tiling sub-bbox: ${bbox}..."
            #echo "${zone_dir}"output_4326_"${bbox_str}".tiff
            echo "${zone_dir}"tile_WGS84_"${bbox_str3}".tiff
            #gdalwarp -overwrite -te ${bbox} -tr 0.00001 -0.00001 "${processed_dir}"output_4326.tiff "${zone_dir}"${PREFIX}"${bbox_str}".tiff
            gdalwarp -overwrite -te ${bbox} -tr 0.00001 -0.00001 "${processed_dir}"output_4326.tiff "${zone_dir}"${PREFIX}"${bbox_str3}".tiff
        done
    done
fi

#echo "Tiling..."
#gdalwarp -overwrite -te ${bbox} "${processed_dir}"output_4326.tiff "${processed_dir}"output_4326_1.tiff




