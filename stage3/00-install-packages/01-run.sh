#!/bin/bash -ex
# the structure of build.sh allows sparation of non-chroot and chroot actiivties

# installing hubaccess .deb file and installing with apt. Based on this: http://bit.ly/2vIAffM
install -v -o 1000 -g 1000 -d ${ROOTFS_DIR}/home/pi/debs
install -v -D files/hubaccess.list ${ROOTFS_DIR}/etc/apt/sources.list.d
install -v -o 1000 -g 1000 -D files/hubaccess_*.deb ${ROOTFS_DIR}/home/pi/debs
on_chroot << EOF
#update-alternatives --install /usr/bin/x-www-browser \
#  x-www-browser /usr/bin/chromium-browser 86
#update-alternatives --install /usr/bin/gnome-www-browser \
#  gnome-www-browser /usr/bin/chromium-browser 86

# should really be in packages, but the calling order's wrong
cd /home/pi/debs
dpkg-scanpackages . /dev/null | gzip -c9 > Packages.gz
apt update
sudo apt --force-yes -y install  hubaccess

EOF
