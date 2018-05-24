#!/bin/bash -ex

DOCKER="docker"
set +e
$DOCKER ps >/dev/null 2>&1
if [ $? != 0 ]; then
	DOCKER="sudo docker"
fi
if ! $DOCKER ps >/dev/null; then
	echo "error connecting to docker:"
	$DOCKER ps
	exit 1
fi
set -e

config_file=()
if [ -f config ]; then
	config_file=("--env-file" "$(pwd)/config")
	source config
fi

# alternates for first and subsequent elements
stages="declare -a STAGES=(0)"   # this hack expands to a declaration of an array that gets fed into the build script in docker container
PI_GEN="pi-gen"
#stages="declare -a STAGES=(1 2 3 4 5)"
#PI_GEN="timcoote/iotaa-pi-gen-stage0:"$SPRINT""
# used in this script, to decide on whether to push the docker image, and sent to the docker run command, too
eval $stages

CONTAINER_NAME=${CONTAINER_NAME:-pigen_work}
CONTINUE=${CONTINUE:-0}
PRESERVE_CONTAINER=${PRESERVE_CONTAINER:-0}

if [ "$*" != "" ] || [ -z "${IMG_NAME}" ]; then
	if [ -z "${IMG_NAME}" ]; then
		echo "IMG_NAME not set in 'config'" 1>&2
		echo 1>&2
	fi
	cat >&2 <<EOF
Usage:
    build-docker.sh [options]
Optional environment arguments: ( =<default> )
    CONTAINER_NAME=pigen_work  set a name for the build container
    CONTINUE=1                 continue from a previously started container
    PRESERVE_CONTAINER=1       keep build container even on successful build
EOF
	exit 1
fi

CONTAINER_EXISTS=$($DOCKER ps -a --filter name="$CONTAINER_NAME" -q)
CONTAINER_RUNNING=$($DOCKER ps --filter name="$CONTAINER_NAME" -q)
if [ "$CONTAINER_RUNNING" != "" ]; then
	echo "The build is already running in container $CONTAINER_NAME. Aborting."
	exit 1
fi
if [ "$CONTAINER_EXISTS" != "" ] && [ "$CONTINUE" != "1" ]; then
	echo "Container $CONTAINER_NAME already exists and you did not specify CONTINUE=1. Aborting."
	echo "You can delete the existing container like this:"
	echo "  $DOCKER rm -v $CONTAINER_NAME"
	exit 1
fi

$DOCKER build -t pi-gen .
if [ "$CONTAINER_EXISTS" != "" ]; then
	trap "echo 'got CTRL+C... please wait 5s'; $DOCKER stop -t 5 ${CONTAINER_NAME}_cont" SIGINT SIGTERM
       time $DOCKER run --privileged \
#      time $DOCKER run --rm --privileged \
                --volumes-from="${CONTAINER_NAME}" --name "${CONTAINER_NAME}_cont" \
                -e IMG_NAME="${IMG_NAME}"\
                -v $(pwd)/config:/pi-gen/config \
                "${PI_GEN}" \
                bash -e -o pipefail -c "dpkg-reconfigure qemu-user-static &&
        cd /pi-gen; ${stages}; source ./build.sh;
	rsync -av work/*/build.log deploy/" &
	wait "$!"
else
	trap "echo 'got CTRL+C... please wait 5s'; $DOCKER stop -t 5 ${CONTAINER_NAME}" SIGINT SIGTERM
	time $DOCKER run --name "${CONTAINER_NAME}" --privileged \
		-e IMG_NAME="${IMG_NAME}"\
                -v $(pwd)/config:/pi-gen/config \
                -v $(pwd)/stage3:/pi-gen/stage3 \
                -v $(pwd)/stage4:/pi-gen/stage4 \
                "${PI_GEN}" \
                bash -e -o pipefail -c "dpkg-reconfigure qemu-user-static &&
        cd /pi-gen; ${stages}; source ./build.sh;
	rsync -av work/*/build.log deploy/" &
	wait "$!"
fi

# now commit that container $SPRINT defined in config
if [ ${STAGES[${#STAGES[@]}-1]} -eq 0 ]
then
    docker commit ${CONTAINER_NAME} timcoote/iotaa-pi-gen-stage0:"$SPRINT"
    # hack to avoid docker login requesting an email address. nb env. vars coming from travis
    echo "tim+github.com@coote.org" | docker login -u "$DOCKER_USERNAME" -p "$DOCKER_PASSWORD"
    docker push timcoote/iotaa-pi-gen-stage0:"$SPRINT"
fi

echo "copying results from deploy/"
$DOCKER cp "${CONTAINER_NAME}":/pi-gen/deploy .
ls -lah deploy

# cleanup
if [ "$PRESERVE_CONTAINER" != "1" ]; then
      $DOCKER rm -v $CONTAINER_NAME
fi

echo "Done! Your image(s) should be in deploy/"
