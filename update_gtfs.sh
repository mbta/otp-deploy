#!/bin/sh

# it's important for MBTA_GFTS to be first file in the folder,
# otherwise realtime alerts won't work: https://github.com/mbta/OpenTripPlanner/pull/8

wget -N https://cdn.mbta.com/MBTA_GTFS.zip -O var/graphs/mbta/1_MBTA_GTFS.zip
wget -N http://data.trilliumtransit.com/gtfs/loganexpress-ma-us/loganexpress-ma-us.zip -O var/graphs/mbta/2_loganexpress-ma-us.zip