#!/bin/sh
IN_MEMORY="--inMemory"
if [ -f "var/graphs/mbta/Graph.obj" ]; then
    IN_MEMORY=""
fi
java -Xmx4G -jar otp-1.3.0-shaded.jar --server --basePath var/ $IN_MEMORY
