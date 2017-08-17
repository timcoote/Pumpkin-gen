#!/bin/bash -ex
# the structure of build.sh allows sparation of non-chroot and chroot actiivties

# installing hubaccess .deb file and installing with apt. Based on this: http://bit.ly/2vIAffM
install -v -o 1000 -g 1000 -d ${ROOTFS_DIR}/home/pi/debs
install -v -m 644 files/hubaccess.list ${ROOTFS_DIR}/etc/apt/sources.list.d
install -v -o 1000 -g 1000 -D files/hubaccess_0.61_all.deb ${ROOTFS_DIR}/home/pi/debs
install -v -o 1000 -g 1000 -D files/pushkeys_0.61_all.deb ${ROOTFS_DIR}/home/pi/debs
install -v -o 1000 -g 1000 -D files/hub-connect_0.0.1_all.deb ${ROOTFS_DIR}/home/pi/debs
on_chroot << EOF
#update-alternatives --install /usr/bin/x-www-browser \
#  x-www-browser /usr/bin/chromium-browser 86
#update-alternatives --install /usr/bin/gnome-www-browser \
#  gnome-www-browser /usr/bin/chromium-browser 86

# set up the local local repo and install the packages
cd /home/pi/debs
dpkg-scanpackages . /dev/null | gzip -c9 > Packages.gz
apt update
sudo apt --force-yes -y install  hubaccess pushkeys hub-connect

EOF
