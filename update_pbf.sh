#!/bin/sh
rm var/graphs/mbta/*.pbf us-northeast-latest.osm.pbf
wget -nc https://download.geofabrik.de/north-america/us-northeast-latest.osm.pbf
~/bin/osmconvert us-northeast-latest.osm.pbf -b=-73.619,41.206,-69.644,42.936 --drop-author -o=var/graphs/mbta/watershed.pbf
