#!/bin/bash

TARGET_ARCH="powerpc-ps3-linux"
TOOLCHAIN_PREFIX="/opt/${TARGET_ARCH}/toolchain"
TOOLCHAIN_SYSROOT="/opt/${TARGET_ARCH}/sysroot"

KERNEL_VERSION="2.6.36"
KERNEL_CONFIG=ps3_kernel_2.6.36
TARGET_VENDOR_PATCH=ps3

. $SETS_DIR/packages-basic.inc

. $RULES_DIR/ps3-utils.sh
. $RULES_DIR/spufs.sh
. $RULES_DIR/tweak-ps3.sh

. $SETS_DIR/packages-host-squashfs4.inc
. $RULES_DIR/create_initramfs.sh
. $RULES_DIR/create_squashfs4.sh
. $RULES_DIR/create_ps3cd.sh
