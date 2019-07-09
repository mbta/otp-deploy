#!/bin/bash

rm -rf onebusaway-gtfs-modules
git clone git@github.com:mbta/onebusaway-gtfs-modules.git --depth 1
pushd onebusaway-gtfs-modules
mvn install -Dmaven.test.skip=true -Dlicense.skip=true
popd

rm -rf OpenTripPlanner
git clone git@github.com:mbta/OpenTripPlanner.git --depth 1