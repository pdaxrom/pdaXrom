#!/bin/bash

TARGET_ARCH="powerpc-linux"
TOOLCHAIN_PREFIX="/opt/${TARGET_ARCH}/toolchain"
TOOLCHAIN_SYSROOT="/opt/${TARGET_ARCH}/sysroot"

KERNEL_VERSION="2.6.29"
KERNEL_CONFIG=ps3_kernel_2.6.29
TARGET_VENDOR_PATCH=ps3

SQUASHFS_LZMA=no

. ./sets/packages-basic.inc

. $RULES_DIR/ps3-utils.sh
. $RULES_DIR/spufs.sh
. $RULES_DIR/tweak-ps3.sh

. ./sets/packages-host-squashfs4.inc
. $RULES_DIR/create_squashfs.sh
. $RULES_DIR/create_ps3cd.sh
