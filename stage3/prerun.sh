#!/bin/bash -ex

if [ ! -d ${ROOTFS_DIR} ]; then
	copy_previous
fi

