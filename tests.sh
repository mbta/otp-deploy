#!/bin/bash

pushd OpenTripPlanner
mvn -Dmaven.repo.local="${M2_CACHE}" clean test -Dgpg.skip -Dmaven.javadoc.skip=true
popd