# Introduction
These are the working notes taken as I was building this process to work in various
environments (vagrant vm, packer vm, vagrant aws, packer aws). There are separate branches
where I was trying to break out the build.sh script so that interim build stages could be cached.
For example, the initial debootstrap phase takes ~12 minutes on each build.

# Current Build Approaches
nb these both apply to the repo that builds this repo, nto this repo itself. They are included here
as a build normallly precedes updating what goes into the build, which is defined here.

## Vagrant
Currently this is probably the most robust and simplest approach.
```
vagrant up --provider=aws
# check the build has uploaded correctly
vagrant destroy
```

## Jenkins
The master branch should be checked out by the jenkins task `SDCardBuilder` in `ansible-pump/vcs`, which
requires running the vm that's described in the checkout and which launches with jenkins on `http://192.168.33.20:8081/jenkins`
login `admin`, password is in the vault somewhere...

# Adding .debs
.debs are installed in stage3/00-install-packages/01-run.sh. The version to use and the package name need inserting. The version
is at the top, eg
```
adminapp_v=1.1.27
```
will use version 1.1.27 (see below in the file). The version must match a package that's available on S3://pumpco.



2018-1-4: working on travis build using build-docker.
Need to be able to split into separate build phases to build/cache docker hub images.

This approach works to pass in an environment variable:
```
# script in file:
BASE=$(pwd)

for i in "${STAGES[@]}" ; do
       for SD in "${BASE}/$i"; do
           echo $SD
       done
done

# and this invocation:
declare -a STAGES=(1 2 3 ); . ./go3.sh 
# creates this output:
/Users/tim/Projects/iotaa/pi-gen/1
/Users/tim/Projects/iotaa/pi-gen/2
/Users/tim/Projects/iotaa/pi-gen/3
# or even somethign like this:
declare -a STAGES=(`seq 1 5`); . ./go3.sh
```

====
working with fpm and building the local repo in /home/pi/debs, this: http://bit.ly/2wPWyAY may show how to remove the error
that started in Stretch complaining about no Release file.

move to Stretch from Jessie firmed up apt's security model, so local repo now needs to be signed.

build out pi-gen (but not much more)
---2017-8-31: reverting some of the debugging changes that I made below with a view to more closely tracking upstream on the dev branch

## the approach below seems to build A disk image, but not clear how to automate within pi-gen, nor what to do about the hubaccess code (CONTAINER_NAME
# is set to pigen_work (as set up on the build-docker.sh script)
docker run --privileged -ti -v /sys/fs/cgroup:/sys/fs/cgroup:ro --volumes-from="${CONTAINER_NAME}" --cap-add=SYS_ADMIN -e IMG_NAME=cutdown pi-gen

log in as tim
sudo su
then paste in the remaingin command:
<cannot find at the moment, the bit over 3 lines, ending with "
# then in a subshell
#
should still work:
systemctl status

then run ./build.sh

we should then be in a position to run the ansible script in smart-home

build.sh fails (this takes 2 hours on my computer) :: need to capture failure: retrying

, but copy/pasting the stage3/00-in<blah>/01-run.sh on_chroot bits now get to hubaccess Get Mac address (which is clearly not something that should
happen as part of the disk image creation process!). can run ansible-playbook with --skip-tags hubaccess. gitlab{user,password} passed in as env variables to the chroot
seems to work.

Disk creation needs to copy the smart-homes code to /home/pi? - did not work as tried initially
--

unsure on where to put the apt/sources.list change for ansible
