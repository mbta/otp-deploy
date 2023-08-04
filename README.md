# OTP Deploy

This repo contains all the deploy scripts, CI/CD, and config files for the MBTA's OpenTripPlanner instance.

## Setup
You'll need to clone this repo run the following from the project root:
1. `asdf install`
1. `mbta/update_gtfs.sh` - fetches latest MBTA and Massport GTFS data
1. `mbta/update_pbf.sh` - updates OpenStreetMap data
1. `mbta/build.sh` - packages OTP into a jar, then runs the OTP build process

If you want to test with your own local GTFS changes, put a copy of your GTFS file (if you've built
one with [`gtfs_creator`](https://github.com/mbta/gtfs_creator), it will be written to
`<gtfs_creator path>/output/google/MBTA_GTFS.zip`) in `var/MBTA_GTFS.gtfs.zip` and re-run the
`build.sh` script.

## Run Locally
With all of that setup done, you should be able to run `mbta/server.sh`. This will start your local
OTP instance and, when ready, print a message saying that the web server is ready and listening.

Open a browser pointing to [`localhost:8080`](http://localhost:8080), and you'll have a bare-bones web interface to OTP where
you can try out trip plans.

## Updating OTP from upstream

This repo uses git submodules to pin OTP to a specific commit and pull the code for use in the build process.
To pull the latest OTP changes, do the following:

1. `git submodule update --init --force --remote`
1. Commit the updated submodule to a feature branch
1. Push and test the update in dev
1. Put up a PR and merge to master once reviewed

## Debugging
If you need to use a debugger, you can run OTP through IntelliJ.

1. Start by adding a new debug configuration,
go to `Edit Configurations` and create a new [Application template, following the IntelliJ
docs](https://www.jetbrains.com/help/idea/run-debug-configuration.html#createExplicitly) using the
values provided below.
   * Java version: Java 17 (browse to your asdf install, usually `~/.asdf/installs/java/<version>`,
   for exact parity with the version used by the build scripts, though any Java 17 JDK is fine)
   * Main class: `org.opentripplanner.standalone.OTPMain`
   * Program arguments: `--load var/`
   * Working directory: `<path to your OTP repo>`
1. You'll also need to [follow the IntelliJ docs to set your SDK in the project
setup](https://www.jetbrains.com/help/idea/sdk.html#change-project-sdk). Again, the most consistent
option is your asdf JDK, but any Java 17 JDK should work.
1. Once the config is created, you can run it normally or as a debugger. If you run into any issues
with the application running out of memory, you can go to `Modify options > Add VM options` in the
edit configuration UI then add the flag `-Xmx8G` to increase the JVM memory pool maximum.

If you need to run or debug the build process for some reason, just create another configuration
with the same values except with program arguments `--build --save var/`.

## Docker
Building and running the docker image locally is usually not necessary, since it's faster to just
run it using the build scripts or IntelliJ.

From the OTP directory:
1. `docker build --platform linux/x86_64 .`
1. `docker images` and copy the image ID of the built image
1. `docker run --platform linux/x86_64 -p 5000:5000 <image id>`

The OTP web interface will then be running at [`localhost:5000`](http://localhost:5000), and you can update the port in your
dotcom `.envrc` to use the docker image end to end locally.

## Deploy
Deploys to prod happen automatically when any changes are merged into `master`. You can manually
perform a dev deploy of any feature branch using the
[deploy workflow](https://github.com/mbta/OpenTripPlanner/actions/workflows/deploy.yml). You can
select the branch you want to deploy and the environment you want to deploy to.

Additionally, deploys to the associated environment are triggered by the
[gtfs_creator](https://github.com/mbta/gtfs_creator) deploy workflows. Any GTFS changes require a
redeploy of OTP, if the triggered pipelines fail, the trip planner will not reflect the latest GTFS
changes until it has been successfully deployed.
