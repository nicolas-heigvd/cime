#!/bin/bash

for f0 in ./data/PROCESSED/output_4326_*.tiff; do
  echo "Processing ${f0}"
  f=${f0##*/}
  tin-terrain dem2tin --input "${f0}" --output ./data/PROCESSED/OBJ/"${f%.*}".obj
done
