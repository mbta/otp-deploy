#!/usr/bin/env bash
set -e

curl -o var/mbta-ma-us.gtfs.zip "${MBTA_GTFS_URL:-"https://mbta-gtfs-s3.s3.amazonaws.com/google_transit.zip"}"
