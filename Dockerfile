# Initialize the OTP builder image
FROM debian:stable as builder

RUN apt-get update && apt-get install -y --no-install-recommends curl git ca-certificates openssh-client

WORKDIR /java/

# Download the JRE for copying to the image to run the OTP server
RUN curl -Lo jre21.tar.gz https://github.com/adoptium/temurin21-binaries/releases/download/jdk-21.0.2%2B13/OpenJDK21U-jre_x64_linux_hotspot_21.0.2_13.tar.gz
RUN tar xvf jre21.tar.gz && rm jre21.tar.gz

# Download the JDK and maven and add them to path for building OTP
RUN curl -Lo jdk21.tar.gz https://github.com/adoptium/temurin21-binaries/releases/download/jdk-21.0.2%2B13/OpenJDK21U-jdk_x64_linux_hotspot_21.0.2_13.tar.gz
RUN tar xvf jdk21.tar.gz && rm jdk21.tar.gz
ENV JAVA_HOME=/java/jdk-21.0.2+13/
ENV PATH="$JAVA_HOME/bin:$PATH"

RUN curl -Lo maven.tar.gz https://archive.apache.org/dist/maven/maven-3/3.9.2/binaries/apache-maven-3.9.2-bin.tar.gz
RUN tar xvf maven.tar.gz && rm maven.tar.gz
ENV PATH="/java/apache-maven-3.9.2/bin/:$PATH"

WORKDIR /build
COPY . .

ARG MBTA_GTFS_URL=https://mbta-gtfs-s3.s3.amazonaws.com/google_transit.zip
ENV MBTA_GTFS_URL="$MBTA_GTFS_URL"

ENV MAX_SEARCH_WINDOW="$MAX_SEARCH_WINDOW"
ENV REMOVE_ITINERARIES_WITH_SAME_ROUTES_AND_STOPS=$REMOVE_ITINERARIES_WITH_SAME_ROUTES_AND_STOPS
ENV SEARCH_WINDOW="$SEARCH_WINDOW"

ARG OTP_REPO
ARG OTP_COMMIT
RUN OTP_REPO="$OTP_REPO" OTP_COMMIT="$OTP_COMMIT" ./scripts/build.sh

# Initialize the OTP runner image
FROM debian:stable-slim as runner
RUN apt-get update && apt-get upgrade -y && apt-get install -y --no-install-recommends dumb-init

RUN useradd -MU otp
USER otp

# Copy the OTP JAR and build artifacts into the final image
COPY --from=builder --chown=otp:otp /build/otp/target/otp-*-shaded.jar /dist/otp.jar
COPY --from=builder --chown=otp:otp /build/var/graph.obj /dist/var/
COPY --from=builder --chown=otp:otp /build/var/*.json /dist/var/
COPY --from=builder --chown=otp:otp /java/jdk-21.0.2+13-jre /java/jdk-21.0.2+13-jre

# Set the default java install to the JRE that was copied into the image rather than the JDK
ENV JAVA_HOME="/java/jdk-21.0.2+13-jre"
ENV PATH="$JAVA_HOME/bin:$PATH"

ARG MBTA_GTFS_URL=https://mbta-gtfs-s3.s3.amazonaws.com/google_transit.zip
ENV MBTA_GTFS_URL="$MBTA_GTFS_URL"
ENV PORT=5000
EXPOSE $PORT

# Run the OTP server, exposed on port 5000
WORKDIR /dist
ENTRYPOINT ["/usr/bin/dumb-init", "--"]
CMD java -Xmx6G -jar otp.jar --load var/ --port ${PORT}
