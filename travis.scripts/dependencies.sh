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

echo "IMG_NAME='travis-pumpkin'"> config 

touch {export-noobs,stage5}/SKIP

time ./build-docker.sh
