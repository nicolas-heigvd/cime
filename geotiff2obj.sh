#!/bin/bash

if [ $# -eq 0 ]
then
    basedir="./DATA/PROCESSED/"
    mkdir -p "${basedir}"ZONE${1}/OBJ/

    for f0 in "${basedir}"ZONE${1}/output_4326_*.tiff; do
      echo "Processing ${f0}"
      f=${f0##*/}
      tin-terrain dem2tin --input "${f0}" --output "${basedir}"ZONE${1}/OBJ/"${f%.*}".obj
    done
else
    echo "Please, give the area number as an argument."
fi
