#!/bin/bash

if [ "x$TARGET_ARCH" = "x" ]; then
TARGET_ARCH="armel-linux-gnueabi"
fi

TOOLCHAIN_PREFIX="/opt/${TARGET_ARCH}/toolchain"
TOOLCHAIN_SYSROOT="/opt/${TARGET_ARCH}/sysroot"

TARGET_VENDOR_PATCH="zaurus"

KERNEL_VERSION="2.6.32"
KERNEL_CONFIG=akita_kernel_2.6.32

U_BOOT_CONFIG=akita
U_BOOT_VERSION=2006-04-18-1106

. $SETS_DIR/packages-basic.inc

. $SETS_DIR/packages-acpi.inc

. $SETS_DIR/packages-mmlibs.inc
. $SETS_DIR/packages-libs.inc

. $RULES_DIR/wpa_supplicant.sh


. $RULES_DIR/kbd.sh
. $RULES_DIR/u-boot.sh
. $BSP_RULES_DIR/survive.sh
. $BSP_RULES_DIR/zaurus_custom.sh
. $BSP_RULES_DIR/create_emer_initrd.sh
