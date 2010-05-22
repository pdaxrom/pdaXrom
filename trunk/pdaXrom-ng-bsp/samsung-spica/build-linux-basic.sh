#!/bin/bash

TARGET_ARCH="armle-spica-linux-gnueabi"
TOOLCHAIN_PREFIX="/opt/${TARGET_ARCH}/toolchain"
TOOLCHAIN_SYSROOT="/opt/${TARGET_ARCH}/sysroot"

export KERNEL_VERSION=2.6.29
export KERNEL_CONFIG=spica-pdaXrom-2.6.29

TARGET_KERNEL_IMAGE=zImage
TARGET_VENDOR_PATCH=samsung-spica

INITRAMFS_MODULES="multipdp vibrator s3c_rotator s3c_mfc s3c_g2d_driver s3c_pp s3c_jpeg s3c_g3d s3c_cmm s3c_camera param btgpio"
INITRAMFS_MODULES_SEQUENCE="multipdp vibrator s3c_rotator s3c_mfc s3c_g2d_driver s3c_pp s3c_jpeg s3c_g3d s3c_cmm s3c_camera param btgpio"

. $SETS_DIR/packages-basic.inc
. $BSP_RULES_DIR/build-spica-mods.sh
. $BSP_RULES_DIR/build-adbd.sh

. $SETS_DIR/packages-host-squashfs.inc
. $RULES_DIR/create_squashfs.sh

. $BSP_RULES_DIR/create_initramfs.sh
