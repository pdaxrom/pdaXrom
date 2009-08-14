#!/bin/bash

TARGET_ARCH="armel-linux-uclibc"
TOOLCHAIN_PREFIX="/opt/${TARGET_ARCH}/toolchain"
TOOLCHAIN_SYSROOT="/opt/${TARGET_ARCH}/sysroot"

KERNEL_VERSION="2.6.10"
KERNEL_CONFIG=archos605_kernel_2.6.10

TARGET_VENDOR_PATCH=archos
TARGET_KERNEL_IMAGE=zImage

KERNEL_OLDCONFIG_ENABLED=no

./generic/cpio-archos605/archos605.sh

. ./sets/packages-basic.inc

. ./sets/packages-devel.inc

#. $RULES_DIR/create_initramfs.sh
#. ./sets/packages-host-mtd-utils.inc
