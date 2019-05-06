#!/bin/bash

# it's important for MBTA_GFTS to be first file in the folder,
# otherwise realtime alerts won't work: https://github.com/mbta/OpenTripPlanner/pull/8

declare -a feeds=("https://mbta-gtfs-s3.s3.amazonaws.com/google_transit.zip"
                  "http://data.trilliumtransit.com/gtfs/loganexpress-ma-us/loganexpress-ma-us.zip"
                  "http://data.trilliumtransit.com/gtfs/berkshire-ma-us/berkshire-ma-us.zip"
                  "http://data.trilliumtransit.com/gtfs/brockton-ma-us/brockton-ma-us.zip"
                  "http://data.trilliumtransit.com/gtfs/capeann-ma-us/capeann-ma-us.zip"
                  "http://data.trilliumtransit.com/gtfs/capecod-ma-us/capecod-ma-us.zip"
                  "http://data.trilliumtransit.com/gtfs/gatra-ma-us/gatra-ma-us.zip"
                  "http://data.trilliumtransit.com/gtfs/lowell-ma-us/lowell-ma-us.zip")

count=${#feeds[@]}

for (( i=0; i<${count}; i++ ));
do
   filename="${feeds[$i]##*/}"
   wget -N "${feeds[$i]}" -O "var/graphs/mbta/${i}_${filename}"
done
