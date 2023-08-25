# OTP Deploy

This repo contains all the deploy scripts, CI/CD, and config files for the MBTA's OpenTripPlanner instance.

## Setup

You'll need to clone this repo run the following from the project root:

1. `asdf install`
1. `direnv allow`
1. `./scripts/update_gtfs.sh` - fetches latest MBTA and Massport GTFS data
1. `./scripts/update_pbf.sh` - updates OpenStreetMap data
1. `./scripts/build.sh` - packages OTP into a jar, then runs the OTP build process

If you want to test with local GTFS changes, put a copy of your GTFS file (if you've built
one with [`gtfs_creator`](https://github.com/mbta/gtfs_creator), it will be written to
`<gtfs_creator path>/output/google/MBTA_GTFS.zip`) in `var/MBTA_GTFS.gtfs.zip` and re-run the
`build.sh` script. Note that it will be overwritten the next time you run `update_gtfs.sh`.

## Run Locally

With all of that setup done, you should be able to run `./scripts/server.sh`. This will start your local
OTP instance and, when ready, print a message saying that the web server is ready and listening.

Open a browser pointing to [`localhost:8080`](http://localhost:8080), and you'll have a bare-bones web interface to OTP
where you can try out trip plans.

## Updating OTP from upstream

This repo uses env vars defined in `.envrc.global` to determine the OTP repo and commit to build with. You can test
locally with a different repo or commit by copying `.envrc.local` from `.envrc.local.template`, setting the values in
there will override the global ones.
The values from `.envrc.global` are read by the `set-otp-build-params` step in `.github/workflows/deploy.yml` and used
in the builds in AWS. You can add more cases there to override these for specific environments if you want to deploy a
different OTP branch for dev testing, though this should only need to be used temporarily for longer term testing.

The OTP_COMMIT var can be set either to a commit hash, or to a branch name. A branch isn't used in prod so that we're
always using a consistent version to build unless we specifically upgrade it. However, it will probably be more
convenient to use a branch locally and in dev, so feel free to set it to a branch in those cases.

To pull the latest OTP changes, do the following:

1. Check the [OpenTripPlanner](https://github.com/opentripplanner/OpenTripPlanner/commits/dev-2.x) repo for the latest
   commit on `dev-2.x` (this is their bleeding-edge release branch)
1. Copy the commit hash
1. Update it in `.envrc.global` and test the changes locally (making sure you're not overwriting them with
   `.envrc.local`)
1. Put up a PR and merge/deploy once approved

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

1. `docker-compose up`

The OTP web interface will then be running at [`localhost:5000`](http://localhost:5000), and you can update your
dotcom `.envrc` to point to this URL to test the docker image end to end locally.

## Deploy

Deploys to prod happen automatically when any changes are merged into `master`. You can manually
perform a dev deploy of any feature branch using the
[deploy workflow](https://github.com/mbta/otp-deploy/actions/workflows/deploy.yml). You can
select the branch you want to deploy and the environment you want to deploy to.

Additionally, deploys to the associated environment are triggered by the
[gtfs_creator](https://github.com/mbta/gtfs_creator) deploy workflows. Any GTFS changes require a
redeploy of OTP, if the triggered pipelines fail, the trip planner will not reflect the latest GTFS
changes until it has been successfully deployed.
