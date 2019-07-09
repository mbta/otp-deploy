#!/bin/bash

pushd onebusaway-gtfs-modules
mvn install -Dmaven.test.skip=true -Dlicense.skip=true
popd

pushd OpenTripPlanner
mvn test -Dgpg.skip -Dmaven.javadoc.skip=true
popd