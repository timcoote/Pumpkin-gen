#!/bin/bash
# this is a reimplementation of the Vagrantfile of the EC2 builder for this repo, for a Travis build
set -ev
# grab dependencies
# copied from dnf, so not working as expected sudo apt install -y docker-compose docker python3-dateutil rng-tools rake awscli python git libselinux-python
sudo apt install -y docker.io rng-tools #awscli #python3-dateutil  rake python git libselinux-python
# increase loopbacks
./loops
# sudo pip install --user awscli
# ARM magic
sudo su -c 'echo -n ":arm:M::\\x7fELF\\x01\\x01\\x01\\x00\\x00\\x00\\x00\\x00\\x00\\x00\\x00\\x00\\x02\\x00\\x28\\x00:\\xff\\xff\\xff\\xff\\xff\\xff\\xff\\x00\\xff\\xff\\xff\\xff\\xff\\xff\\xff\\xff\\xfe\\xff\\xff\\xff:/usr/bin/qemu-arm-static:" > /proc/sys/fs/binfmt_misc/register  || true' # true in case the scrips has run before
# launch the build and upload results
rake

touch {export-noobs,stage5}/SKIP

# comment in/out these two lines to get travis to upload an initial docker image for stage0 (also tried modifying to stage2). If left, travis will timeout, before completiion
time ./build-docker.sh
#docker rm -v pigen_work
#time ./build-docker2.sh

aws s3 sync --exact-timestamps --region eu-west-2  --exclude "*" --include "*.zip" --include "*.info" deploy/ s3://pumpco
