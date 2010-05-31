#!/bin/bash

if [ "x$TARGET_ARCH" = "x" ]; then
TARGET_ARCH="armel-linux-gnueabi"
fi

TOOLCHAIN_PREFIX="/opt/${TARGET_ARCH}/toolchain"
TOOLCHAIN_SYSROOT="/opt/${TARGET_ARCH}/sysroot"

TARGET_VENDOR_PATCH="zaurus"

KERNEL_VERSION="2.6.34"
KERNEL_CONFIG=akita_kernel_2.6.34_kexecboot

. ./rules/core.sh

. $RULES_DIR/create_root.sh
. $RULES_DIR/kexecboot.sh
. $RULES_DIR/linux_kernel.sh

. $BSP_RULES_DIR/create_kexecboot_initramfs.sh
