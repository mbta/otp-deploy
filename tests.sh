#!/bin/bash

rm -rf OpenTripPlanner
git clone git@github.com:mbta/OpenTripPlanner.git --depth 1
pushd OpenTripPlanner
mvn test -Dgpg.skip -Dmaven.javadoc.skip=true
popd