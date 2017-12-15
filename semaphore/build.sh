#!/bin/bash
# should be run as ./semaphore/build.sh
set -e

# fetch osmconvert script needed to work with the PBF file
# http://wiki.openstreetmap.org/wiki/Osmconvert#Linux
mkdir -p ~/bin
wget -O ~/bin/osmconvert http://m.m.i24.cc/osmconvert64
chmod +x ~/bin/osmconvert

./update_pbf.sh
./update_gtfs.sh
./build.sh
./make_deploy.sh
