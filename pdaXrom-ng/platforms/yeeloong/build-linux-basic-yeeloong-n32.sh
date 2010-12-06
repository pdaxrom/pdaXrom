#!/bin/bash

TARGET_ARCH="mips64el-ls2f-linux"
TOOLCHAIN_PREFIX="/opt/${TARGET_ARCH}/toolchain"
TOOLCHAIN_SYSROOT="/opt/${TARGET_ARCH}/sysroot"

TARGET_VENDOR_PATCH=ls2f

KERNEL_VERSION=2.6.36
KERNEL_CONFIG=lemote2f_minimal_2.6.36

CROSS_OPT_ARCH="-march=loongson2f -mtune=loongson2f"

USE_AUFS2="yes"

. $SETS_DIR/packages-basic.inc
. $SETS_DIR/packages-mmlibs.inc

. $SETS_DIR/packages-host-squashfs4.inc
. $RULES_DIR/create_initramfs.sh
. $RULES_DIR/create_squashfs4.sh

. $RULES_DIR/create_lemote.sh
