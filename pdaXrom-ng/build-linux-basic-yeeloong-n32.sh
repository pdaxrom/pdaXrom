#!/bin/bash

TARGET_ARCH="mips64el-ls2f-linux"
TOOLCHAIN_PREFIX="/opt/${TARGET_ARCH}/toolchain"
TOOLCHAIN_SYSROOT="/opt/${TARGET_ARCH}/sysroot"

TARGET_VENDOR_PATCH=ls2f

KERNEL_VERSION="2.6.30"
KERNEL_CONFIG=yeeloong2f_2.6.30.5

CROSS_OPT_ARCH="-march=loongson2f -mtune=loongson2f"
#CROSS_OPT_CFLAGS="-O3"
#CROSS_OPT_CXXFLAGS="-O3"

. ./sets/packages-basic.inc
. ./sets/packages-mmlibs.inc

. ./sets/packages-host-squashfs.inc
. $RULES_DIR/create_initramfs.sh
. $RULES_DIR/create_squashfs.sh

. $RULES_DIR/create_lemote.sh
