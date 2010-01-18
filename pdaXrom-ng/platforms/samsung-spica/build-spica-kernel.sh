#!/bin/bash

TARGET_ARCH="armle-spica-linux-uclibcgnueabi"
TOOLCHAIN_PREFIX="/opt/${TARGET_ARCH}/toolchain"
TOOLCHAIN_SYSROOT="/opt/${TARGET_ARCH}/sysroot"

export KERNEL_VERSION=2.6.27
export KERNEL_CONFIG=spica-kernel-2.6.27

TARGET_KERNEL_IMAGE=zImage
TARGET_VENDOR_PATCH=samsung-spica

BUSYBOX_CONFIG=config-sysutils

. ./rules/core.sh

. $RULES_DIR/host_pkgconfig.sh
. $RULES_DIR/host_findutils.sh
. $RULES_DIR/create_root.sh
. $RULES_DIR/linux_kernel.sh
. $BSP_RULES_DIR/build-spica-mods.sh
. $BSP_RULES_DIR/build-su.sh
. $RULES_DIR/busybox.sh

. $BSP_RULES_DIR/create_android_initramfs.sh
