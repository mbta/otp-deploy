# Initialize the OTP builder image
FROM debian:stable as builder

RUN apt-get update && apt-get install -y --no-install-recommends curl git ca-certificates openssh-client

WORKDIR /java/

# Download the JRE for copying to the image to run the OTP server
RUN curl -Lo jre17.tar.gz https://github.com/adoptium/temurin17-binaries/releases/download/jdk-17.0.7%2B7/OpenJDK17U-jre_x64_linux_hotspot_17.0.7_7.tar.gz
RUN tar xvf jre17.tar.gz && rm jre17.tar.gz

# Download the JDK and maven and add them to path for building OTP
RUN curl -Lo jdk17.tar.gz https://github.com/adoptium/temurin17-binaries/releases/download/jdk-17.0.7%2B7/OpenJDK17U-jdk_x64_linux_hotspot_17.0.7_7.tar.gz
RUN tar xvf jdk17.tar.gz && rm jdk17.tar.gz
ENV JAVA_HOME=/java/jdk-17.0.7+7/
ENV PATH="$JAVA_HOME/bin:$PATH"

RUN curl -Lo maven.tar.gz https://archive.apache.org/dist/maven/maven-3/3.9.2/binaries/apache-maven-3.9.2-bin.tar.gz
RUN tar xvf maven.tar.gz && rm maven.tar.gz
ENV PATH="/java/apache-maven-3.9.2/bin/:$PATH"

# Download the latest GTFS and PBF files, then build OTP
WORKDIR /build
COPY . .
ARG MBTA_GTFS_URL=https://mbta-gtfs-s3.s3.amazonaws.com/google_transit.zip
RUN MBTA_GTFS_URL="$MBTA_GTFS_URL" ./scripts/update_gtfs.sh
RUN ./scripts/update_pbf.sh
RUN ./scripts/build.sh

# Initialize the OTP runner image
FROM debian:stable-slim as runner
RUN apt-get update && apt-get upgrade -y && apt-get install -y --no-install-recommends dumb-init

RUN useradd -MU otp
USER otp

# Copy the OTP JAR and build artifacts into the final image
COPY --from=builder --chown=otp:otp /build/otp/target/otp-*-shaded.jar /dist/otp.jar
COPY --from=builder --chown=otp:otp /build/var/graph.obj /dist/var/
COPY --from=builder --chown=otp:otp /build/var/*.json /dist/var/
COPY --from=builder --chown=otp:otp /java/jdk-17.0.7+7-jre /java/jdk-17.0.7+7-jre

# Set the default java install to the JRE that was copied into the image rather than the JDK
ENV JAVA_HOME="/java/jdk-17.0.7+7-jre"
ENV PATH="$JAVA_HOME/bin:$PATH"

ENV PORT=5000
EXPOSE $PORT

# Run the OTP server, exposed on port 5000
WORKDIR /dist
ENTRYPOINT ["/usr/bin/dumb-init", "--"]
CMD java -Xmx6G -jar otp.jar --load var/ --port ${PORT}
