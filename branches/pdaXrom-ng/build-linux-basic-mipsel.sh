#!/bin/bash

TARGET_ARCH="mipsel-linux"
TOOLCHAIN_PREFIX="/opt/${TARGET_ARCH}/toolchain"
TOOLCHAIN_SYSROOT="/opt/${TARGET_ARCH}/sysroot"

KERNEL_VERSION="2.6.28"
KERNEL_CONFIG=malta_kernel_2.6.28

. ./sets/packages-basic.inc

. ./sets/packages-host-squashfs.inc
. $RULES_DIR/create_initramfs.sh
