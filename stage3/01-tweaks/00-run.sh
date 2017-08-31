#!/bin/bash -ex
echo "in tweaks"

echo ${ROOTFS_DIR}
ls ${ROOTFS_DIR}
apt update

apt install lsof


rm -f ${ROOTFS_DIR}/etc/systemd/system/dhcpcd.service.d/wait.conf
lsof
