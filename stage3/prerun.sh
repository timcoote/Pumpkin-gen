#!/bin/bash -ex
if [ ! -d ${ROOTFS_DIR} ]; then
	copy_previous
fi

pwd
ls -l
cp -r ../smart-home ${ROOTFS_DIR}
