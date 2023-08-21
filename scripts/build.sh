#!/usr/bin/env bash
set -e

git clone https://github.com/opentripplanner/OpenTripPlanner.git otp || true

cd otp
git checkout b391945480c37eaffc881df427700ef351b4b19d

mvn clean package -U -Dmaven.test.skip=true -Dgpg.skip -Dmaven.javadoc.skip=true

cd ..
java -Xmx8G -jar otp/target/otp-*-shaded.jar --build --save var/
