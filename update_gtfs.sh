#!/bin/sh
wget -N https://mbta-gtfs-s3.s3.amazonaws.com/google_transit.zip -O var/graphs/mbta/google_transit.zip
wget -N http://data.trilliumtransit.com/gtfs/loganexpress-ma-us/loganexpress-ma-us.zip -O var/graphs/mbta/loganexpress-ma-us.zip