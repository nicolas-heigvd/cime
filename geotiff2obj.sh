#!/bin/bash

basedir="./DATA/PROCESSED/"
for f0 in "${basedir}"ZONE${1}/output_4326_*.tiff; do
  echo "Processing ${f0}"
  f=${f0##*/}
  tin-terrain dem2tin --input "${f0}" --output "${basedir}"ZONE${1}/OBJ/"${f%.*}".obj
done
