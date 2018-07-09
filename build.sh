#!/bin/sh

# ensure we use Java 8; other versions have an issue building the graph:
# https://groups.google.com/forum/#!topic/opentripplanner-users/pvtm3BSyS9g
export JAVA_HOME=$(/usr/libexec/java_home -v 1.8)

java -Xmx4G -jar otp-1.2.0-shaded.jar --build var/graphs/mbta/ --basePath var/
