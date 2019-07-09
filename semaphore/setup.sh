#!/bin/bash

rm -rf onebusaway-gtfs-modules
git clone git@github.com:mbta/onebusaway-gtfs-modules.git --depth 1

rm -rf OpenTripPlanner
git clone git@github.com:mbta/OpenTripPlanner.git --depth 1