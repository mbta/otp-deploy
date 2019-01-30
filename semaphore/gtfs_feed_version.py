#/usr/bin/env python
import csv
import zipfile

with zipfile.ZipFile("var/graphs/mbta/google_transit.zip", "r") as zf:
    with zf.open("feed_info.txt") as feed_info:
        for row in csv.DictReader(feed_info):
            print row["feed_version"]
