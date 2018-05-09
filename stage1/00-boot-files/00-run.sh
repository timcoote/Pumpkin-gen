#!/bin/bash -e

install -m 644 files/cmdline.txt "${ROOTFS_DIR}/boot/"
install -m 644 files/config.txt "${ROOTFS_DIR}/boot/"
# documentation: what's this for? I added it! - mtc
touch ${ROOTFS_DIR}/boot/ssh
