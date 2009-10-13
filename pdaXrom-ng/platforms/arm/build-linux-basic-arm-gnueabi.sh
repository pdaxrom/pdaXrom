#!/bin/bash

TARGET_ARCH="armel-linux-gnueabi"
TOOLCHAIN_PREFIX="/opt/${TARGET_ARCH}/toolchain"
TOOLCHAIN_SYSROOT="/opt/${TARGET_ARCH}/sysroot"

KERNEL_VERSION="2.6.28"
KERNEL_CONFIG=versatile-kernel-2.6.28

U_BOOT_VERSION=2009.08
U_BOOT_CONFIG=versatilepb

. ./sets/packages-basic.inc

. $RULES_DIR/u-boot.sh

. ./sets/packages-host-squashfs.inc
. $RULES_DIR/create_squashfs.sh
