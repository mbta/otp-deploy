#!/bin/bash
set -e

pushd OpenTripPlanner
mvn -Dmaven.repo.local="${SEMAPHORE_CACHE_DIR}/.m2/" clean test -Dgpg.skip -Dmaven.javadoc.skip=true
popd