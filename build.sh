#!/bin/bash

# ensure we use Java 8; other versions have an issue building the graph:
# https://groups.google.com/forum/#!topic/opentripplanner-users/pvtm3BSyS9g
source /opt/change-java-version.sh
change-java-version 8

rm -rf onebusaway-gtfs-modules
git clone git@github.com:mbta/onebusaway-gtfs-modules.git --depth 1
pushd onebusaway-gtfs-modules
mvn clean install -Dmaven.test.skip=true -Dlicense.skip=true
popd

rm -rf OpenTripPlanner
git clone git@github.com:mbta/OpenTripPlanner.git -b lev-sort-gtfs-files --depth 1
pushd OpenTripPlanner
mvn clean install -Dmaven.test.skip=true -Dgpg.skip -Dmaven.javadoc.skip=true
popd

cp ./OpenTripPlanner/target/otp-1.4.0-SNAPSHOT-shaded.jar .
java -Xmx4G -jar otp-1.4.0-SNAPSHOT-shaded.jar --build var/graphs/mbta/ --basePath var/
