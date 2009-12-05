#!/bin/bash

TARGET_ARCH="armel-linux-gnueabi"
TOOLCHAIN_PREFIX="/opt/${TARGET_ARCH}/toolchain"
TOOLCHAIN_SYSROOT="/opt/${TARGET_ARCH}/sysroot"

TARGET_VENDOR_PATCH="zaurus"

KERNEL_VERSION="2.6.32"
KERNEL_CONFIG=akita_kernel_2.6.32

U_BOOT_CONFIG=akita
U_BOOT_VERSION=2006-04-18-1106

. $SETS_DIR/packages-basic.inc
. $RULES_DIR/u-boot.sh
. $SETS_DIR/packages-host-squashfs.inc
. $RULES_DIR/create_squashfs.sh
