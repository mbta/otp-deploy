#!/bin/bash
set -e

pushd OpenTripPlanner
mvn -Dmaven.repo.local="${SEMAPHORE_CACHE_DIR}/.m2/" clean install -Dmaven.test.skip=true -Dgpg.skip -Dmaven.javadoc.skip=true
popd

cp ./OpenTripPlanner/target/otp-1.4.0-SNAPSHOT-shaded.jar .
java -Xmx4G -jar otp-1.4.0-SNAPSHOT-shaded.jar --build var/graphs/mbta/ --basePath var/
