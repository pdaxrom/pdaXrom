#!/bin/bash

if [ "x$TARGET_ARCH" = "x" ]; then
TARGET_ARCH="armel-linux-gnueabi"
fi

TOOLCHAIN_PREFIX="/opt/${TARGET_ARCH}/toolchain"
TOOLCHAIN_SYSROOT="/opt/${TARGET_ARCH}/sysroot"

TARGET_VENDOR_PATCH="zaurus"

KERNEL_VERSION="2.6.32"
KERNEL_CONFIG=akita_kernel_2.6.32

. $SETS_DIR/packages-basic.inc
. $SETS_DIR/packages-libs.inc
. $RULES_DIR/kbd.sh
. $RULES_DIR/host_lzo.sh
. $RULES_DIR/host_e2fsprogs.sh
. $RULES_DIR/host_mtd-utils.sh
. $BSP_RULES_DIR/zaurus_custom.sh
. $BSP_RULES_DIR/create_jffs2.sh
