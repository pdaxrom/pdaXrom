#!/bin/bash

TARGET_ARCH="armel-linux-gnueabi"
TOOLCHAIN_PREFIX="/opt/${TARGET_ARCH}/toolchain"
TOOLCHAIN_SYSROOT="/opt/${TARGET_ARCH}/sysroot"
U_BOOT_CONFIG=akita_config
KERNEL_VERSION="2.6.29.1"
KERNEL_CONFIG=akita_kernel_2.6.29.1
TARGET_VENDOR_PATCH=akita

. ./sets/packages-basic.inc
. $RULES_DIR/u-boot.sh
. ./sets/packages-host-squashfs.inc
. $RULES_DIR/create_squashfs.sh
