#!/bin/sh
rm mbta_otp.zip
zip mbta_otp.zip Procfile lucene/** otp-1.1.0-shaded.jar var/graphs/mbta/Graph.obj
