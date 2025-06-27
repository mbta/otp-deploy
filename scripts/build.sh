#!/usr/bin/env bash
set -e

if [ -z "$OTP_REPO" ]; then
    echo "No repo was provided to pull from, you must set the OTP_REPO env var to the OpenTripPlanner repo you want to use"
    exit 1
elif [ -z "$OTP_COMMIT" ]; then
    echo "No OTP commit was provided, you must set the OTP_COMMIT env var to the hash or branch you want to build with"
    exit 1
fi

echo "Building OTP with" $OTP_REPO "at" $OTP_COMMIT
git clone $OTP_REPO otp || true

cd otp
git fetch $OTP_REPO # in case the repo already existed
git checkout $OTP_COMMIT

mvn clean package -U -Dmaven.test.skip=true -Dgpg.skip -Dmaven.javadoc.skip=true

cd ..
# TODO write better script (the wildcards were matching otp-shaded-2.8.0-SNAPSHOT-sources.jar instead of the right one)
java -Xmx8G -jar otp/otp-shaded/target/otp-shaded-2.8.0-SNAPSHOT.jar --build --save var/
