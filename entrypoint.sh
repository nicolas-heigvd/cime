#!/bin/bash

echo "Entered /data/entrypoint.sh";
echo $(pwd);

echo "Cutting operation in zone 1...";
/bin/bash ./wgs84_grid_cut.sh 1;
echo "Cutting operation in zone 2...";
/bin/bash ./wgs84_grid_cut.sh 2;
echo "Conversion to OBJ in zone 1...";
/bin/bash ./geotiff2obj.sh 1;
echo "Conversion to OBJ in zone 1...";
/bin/bash ./geotiff2obj.sh 2;
echo "Processing finised successfully!";
