#!/bin/bash

source $(pwd)"/.env"

if [ $# -ne 1 ]
then
    echo "Please, give the area number as an argument."
else
    basedir="/data/DATA/PROCESSED/"
    mkdir -p "${basedir}"ZONE${1}/OBJ/

    for f0 in "${basedir}"ZONE${1}/${PREFIX}*.tiff; do
      echo "Processing ${f0}"
      f=${f0##*/}
      tin-terrain dem2tin --input "${f0}" --output "${basedir}"ZONE${1}/OBJ/"${f%.*}".obj
    done
fi
