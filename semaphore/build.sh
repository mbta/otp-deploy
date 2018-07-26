#!/bin/bash
# should be run as ./semaphore/build.sh
set -e

./update_pbf.sh
./update_gtfs.sh
./build.sh
./make_deploy.sh
