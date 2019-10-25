#!/bin/bash -ex
# the structure of build.sh allows sparation of non-chroot and chroot actiivties
ha_v=1.08
hc_v=2.7
config_v=1.5
sens_v=0.8
filebeat_v=0.55
hubdaemon_v=1.66.17
bcg_p_v=0.23

# installing hubaccess .deb file and installing with apt. Based on this: http://bit.ly/2vIAffM
install -v -o 1000 -g 1000 -d ${ROOTFS_DIR}/home/pi/debs
install -v -o 1000 -g 1000 -d ${ROOTFS_DIR}/home/pi/.vnc
install -v -m 644 files/hubaccess.list ${ROOTFS_DIR}/etc/apt/sources.list.d
install -v -m 644 files/pumpkin.conf ${ROOTFS_DIR}/etc/sysctl.d
install -v -o 1000 -g 1000 -D files/hubaccess_${ha_v}_all.deb ${ROOTFS_DIR}/home/pi/debs
install -v -o 1000 -g 1000 -D files/pushkeys_${ha_v}_all.deb ${ROOTFS_DIR}/home/pi/debs
install -v -o 1000 -g 1000 -D files/pumpkin-config_${config_v}_all.deb ${ROOTFS_DIR}/home/pi/debs
install -v -o 1000 -g 1000 -D files/hub-connect2_${hc_v}_all.deb ${ROOTFS_DIR}/home/pi/debs
install -v -o 1000 -g 1000 -D files/sensei2_${sens_v}_all.deb ${ROOTFS_DIR}/home/pi/debs
install -v -o 1000 -g 1000 -D files/filebeat_${filebeat_v}_all.deb ${ROOTFS_DIR}/home/pi/debs
install -v -o 1000 -g 1000 -D files/hubdaemon_${hubdaemon_v}_all.deb ${ROOTFS_DIR}/home/pi/debs
install -v -o 1000 -g 1000 -D files/bcg-presenceservice_${bcg_p_v}_all.deb ${ROOTFS_DIR}/home/pi/debs
install -v -o 1000 -g 1000 -D files/gpgkeyin ${ROOTFS_DIR}/home/pi
install -v -m 600 -o 1000 -g 1000 -D files/passwd ${ROOTFS_DIR}/home/pi/.vnc
install -v -m 600 -D files/wpa_supplicant.conf ${ROOTFS_DIR}/etc/wpa_supplicant/wpa_supplicant.conf
#install -v -D files/tightvnc.service ${ROOTFS_DIR}/lib/systemd/system/tightvnc.service
install -v -o 1000 -g 1000 -D files/autostart ${ROOTFS_DIR}/home/pi/.config/lxsession/LXDE-pi/autostart
on_chroot << EOF

# https://superuser.com/a/884191
# create a user that our service will run as
set -x
adduser --system --no-create-home --disabled-login --group sensei

# add user sense to the dialout group so that our service can access the zstick
adduser sensei dialout


#update-alternatives --install /usr/bin/x-www-browser \
#  x-www-browser /usr/bin/chromium-browser 86
#update-alternatives --install /usr/bin/gnome-www-browser \
#  gnome-www-browser /usr/bin/chromium-browser 86

# set up the local local repo and install the packages
# mostly from here: http://bit.ly/2wPWyAY, but apt-secure has changed some of the behaviours
# generates a new, unprotected key each time. Silly, but I cannot see how to avoid the complexity
## should this go into a 00-run-chroot.sh?

cd /home/pi/

gpg --batch --gen-key gpgkeyin
gpg -a --export > localpubkey.asc
cat localpubkey.asc | apt-key add -
cd debs
# Packages.gz does not now seem to be used, but uncompressed file seems to be essential
dpkg-scanpackages . /dev/null > Packages
# gzip -c9 Packages> Packages.gz
apt-ftparchive release . > Release
gpg --batch --yes --clearsign --output  InRelease Release
apt update  -y
# otherwise the chroot /dev directory remains busy
gpgconf --kill gpg-agent
# --force-yes is deprecated, so removed. If / when a useful error occurs the newer --allow flag could be used
# or move these to one of the xx-packages files
curl -sL https://deb.nodesource.com/setup_8.x | bash -
# temp move of bcg-presenceservice to stage4 as its pre.sh runs pip3, which isn't installed, yet.
apt -y install hubaccess pushkeys pumpkin-config sensei2 hub-connect2 filebeat hubdaemon

EOF
