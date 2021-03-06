#!/bin/bash

TARGET_ARCH="armle-spica-linux-gnueabi"
TOOLCHAIN_PREFIX="/opt/${TARGET_ARCH}/toolchain"
TOOLCHAIN_SYSROOT="/opt/${TARGET_ARCH}/sysroot"

export KERNEL_VERSION=2.6.32
export KERNEL_CONFIG=ipod1g-2.6.32

TARGET_KERNEL_IMAGE=zImage
TARGET_VENDOR_PATCH=ipod1g

INITRAMFS_INIT="init.initramfs-psfreedom"

INITRAMFS_MODULES="psfreedom"
INITRAMFS_MODULES_SEQUENCE="psfreedom"

. $SETS_DIR/packages-basic.inc

. $BSP_RULES_DIR/PSFreedom.sh

. $BSP_RULES_DIR/create_initramfs.sh
