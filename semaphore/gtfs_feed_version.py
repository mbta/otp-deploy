#/usr/bin/env python
import csv
import zipfile

with zipfile.ZipFile("var/graphs/mbta/1_MBTA_GTFS.zip", "r") as zf:
    with zf.open("feed_info.txt") as feed_info:
        for row in csv.DictReader(feed_info):
            print row["feed_version"]
