#!/bin/bash

pushd OpenTripPlanner
mvn test -Dgpg.skip -Dmaven.javadoc.skip=true
popd