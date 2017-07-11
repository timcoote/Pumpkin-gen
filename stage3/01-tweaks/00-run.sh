#!/bin/bash -ex
echo "in tweaks"

echo ${ROOTFS_DIR}
ls ${ROOTFS_DIR}

rm -f ${ROOTFS_DIR}/etc/systemd/system/dhcpcd.service.d/wait.conf
