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

CONTAINER_NAME=${CONTAINER_NAME:-pigen_work}
CONTINUE=${CONTINUE:-0}

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
    CONTINUE=0                  continue from a previously started container
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

$DOCKER build -t pi-gen -f Dockerfile .
#$DOCKER pull localhost:5000/iotaa-pi-gen

if [ "$CONTAINER_EXISTS" != "" ]; then
	trap "echo 'got CTRL+C... please wait 5s'; $DOCKER stop -t 5 ${CONTAINER_NAME}_cont" SIGINT SIGTERM
#      time $DOCKER run --rm --privileged \
#		timcoote/iotaa:latest \
       time $DOCKER run --privileged \
		-e IMG_NAME="${IMG_NAME}"\
                pi-gen \
        bash -e -o pipefail -c "dpkg-reconfigure qemu-user-static &&
        cd /pi-gen; declare -a STAGES=(0); source ./build4.sh;
	rsync -av work/*/build.log deploy/" &
	wait "$!"
else
	trap "echo 'got CTRL+C... please wait 5s'; $DOCKER stop -t 5 ${CONTAINER_NAME}" SIGINT SIGTERM
#		pi-gen \
	time $DOCKER run --name "${CONTAINER_NAME}" --privileged \
		-e IMG_NAME="${IMG_NAME}"\
		"${config_file[@]}" \
                pi-gen \
		bash -e -o pipefail -c "dpkg-reconfigure qemu-user-static &&
        cd /pi-gen; declare -a STAGES=(0); source ./build4.sh;
	rsync -av work/*/build.log deploy/" &
	wait "$!"
fi

# now commit that container
# this is not working correctly as it's picking up the wrong container. Need to use the containers name?
#docker commit $(docker ps -a|head -2| tail -1|awk '{print $1}') localhost:5000/iotaa-pi-gen-stage0
docker commit ${CONTAINER_NAME} timcoote/iotaa-pi-gen-stage0:"$SPRINT"
# hack to avoid docker login requesting an email address
docker login -u "$DOCKER_USERNAME" -p "$DOCKER_PASSWORD"
docker push timcoote/iotaa-pi-gen-stage0:"$SPRINT"
#echo "copying results from deploy/"
#$DOCKER cp "${CONTAINER_NAME}":/pi-gen/deploy .
#ls -lah deploy
#$DOCKER rm -v $CONTAINER_NAME

#echo "Done! Your image(s) should be in deploy/"
