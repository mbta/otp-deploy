#!/bin/sh
rm mbta_otp.zip
zip mbta_otp.zip Procfile otp-1.2.0-SNAPSHOT-shaded.jar var/graphs/mbta/Graph.obj var/graphs/mbta/*.json
