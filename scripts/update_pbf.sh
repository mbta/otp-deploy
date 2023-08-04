#!/usr/bin/env bash
set -e

rm -rf var/*.pbf
for filename in massachusetts-latest.osm.pbf rhode-island-latest.osm.pbf; do
    curl --output-dir var/ -O http://download.geofabrik.de/north-america/us/$filename
done
