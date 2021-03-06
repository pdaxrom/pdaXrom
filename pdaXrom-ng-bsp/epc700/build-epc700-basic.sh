#!/bin/bash

TARGET_ARCH="mipsel-jz-linux"
TOOLCHAIN_PREFIX="/opt/${TARGET_ARCH}/toolchain"
TOOLCHAIN_SYSROOT="/opt/${TARGET_ARCH}/sysroot"

KERNEL_VERSION="2.6.24.3"
KERNEL_CONFIG=epc700_kernel_2.6.24

TARGET_VENDOR_PATCH=jz
TARGET_KERNEL_IMAGE=uImage

#TARGET_JFFS2_ERASEBLOCK=16384
#TARGET_JFFS2_PAGESIZE=4096
#TARGET_JFFS2_ARGS="-p -n"

. $SETS_DIR/packages-basic.inc

#. $RULES_DIR/tweak-stb610.sh
. $RULES_DIR/create_initramfs.sh

#. $SETS_DIR/packages-host-mtd-utils.inc
#. $RULES_DIR/create_jffs2.sh

SQUASHFS_LZMA=no

. $SETS_DIR/packages-host-squashfs.inc
. $RULES_DIR/create_squashfs.sh

. $RULES_DIR/create_epc700.sh
