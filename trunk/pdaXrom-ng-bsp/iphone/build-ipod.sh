#!/bin/bash

TARGET_ARCH="armle-spica-linux-gnueabi"
TOOLCHAIN_PREFIX="/opt/${TARGET_ARCH}/toolchain"
TOOLCHAIN_SYSROOT="/opt/${TARGET_ARCH}/sysroot"

export KERNEL_VERSION=2.6.32
export KERNEL_CONFIG=ipod1g-2.6.32-new

TARGET_KERNEL_IMAGE=zImage
TARGET_VENDOR_PATCH=ipod1g

USE_AUFS2="yes"

#INITRAMFS_MODULES="psfreedom"
#INITRAMFS_MODULES_SEQUENCE="psfreedom"

. $SETS_DIR/packages-basic.inc
. $BSP_RULES_DIR/PSFreedom.sh
. $SETS_DIR/packages-mmlibs.inc
. $SETS_DIR/packages-libs.inc
. $RULES_DIR/wpa_supplicant.sh

$INSTALL -m 644 ${BSP_GENERICFS_DIR}/modules ${ROOTFS_DIR}/etc/
$INSTALL -m 644 ${BSP_GENERICFS_DIR}/inittab ${ROOTFS_DIR}/etc/
$INSTALL -m 644 ${BSP_GENERICFS_DIR}/rc.local ${ROOTFS_DIR}/etc/

. $SETS_DIR/packages-host-squashfs.inc
. $RULES_DIR/create_squashfs.sh

#. $RULES_DIR/create_ext2img.sh
. $BSP_RULES_DIR/create_initramfs.sh
