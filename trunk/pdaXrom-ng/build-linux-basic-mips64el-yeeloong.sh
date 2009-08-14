#!/bin/bash

TARGET_ARCH="mips64el-linux"
TOOLCHAIN_PREFIX="/opt/${TARGET_ARCH}/toolchain"
TOOLCHAIN_SYSROOT="/opt/${TARGET_ARCH}/sysroot"

TARGET_VENDOR_PATCH=ls2f

KERNEL_VERSION="2.6.29.2"
KERNEL_CONFIG=yeeloong_2.6.29.2

. ./sets/packages-basic.inc

. ./sets/packages-host-squashfs.inc
. $RULES_DIR/create_squashfs.sh
