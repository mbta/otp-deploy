#!/usr/bin/env bash
set -e

git submodule update --init --force

cd OpenTripPlanner
mvn clean package -U -Dmaven.test.skip=true -Dgpg.skip -Dmaven.javadoc.skip=true
cp ./target/otp-*-shaded.jar ../otp.jar

cd ..
java -Xmx8G -jar otp.jar --build --save var/
