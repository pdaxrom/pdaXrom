#!/bin/bash

TARGET_ARCH="mipsel-ls2f-linux"
TOOLCHAIN_PREFIX="/opt/${TARGET_ARCH}/toolchain"
TOOLCHAIN_SYSROOT="/opt/${TARGET_ARCH}/sysroot"

TARGET_VENDOR_PATCH=ls2f

KERNEL_VERSION="2.6.30.2"
KERNEL_CONFIG=yeeloong2f_2.6.30.2

SQUASHFS_LZMA=no

. ./sets/packages-basic.inc
. ./sets/packages-mmlibs.inc

. ./sets/packages-host-squashfs.inc
. $RULES_DIR/create_squashfs.sh
