#!/bin/bash

if [ "x$TARGET_ARCH" = "x" ]; then
TARGET_ARCH="armel-linux-gnueabi"
fi

TOOLCHAIN_PREFIX="/opt/${TARGET_ARCH}/toolchain"
TOOLCHAIN_SYSROOT="/opt/${TARGET_ARCH}/sysroot"

TARGET_VENDOR_PATCH="zaurus"
TARGET_BUILD="spitz"
KERNEL_VERSION="2.6.32"
KERNEL_CONFIG=akita_kernel_2.6.32_full
U_BOOT_CONFIG=akita
U_BOOT_VERSION=2006-04-18-1106
ENABLE_TSLIB="y"

. $SETS_DIR/packages-basic.inc
. $RULES_DIR/host_e2fsprogs.sh
. $SETS_DIR/packages-mmlibs.inc
. $SETS_DIR/packages-libs.inc

. $SETS_DIR/packages-acpi.inc
. $RULES_DIR/wpa_supplicant.sh
. $RULES_DIR/e2fsprogs.sh

. $SETS_DIR/packages-xorg-xlib.inc
. $SETS_DIR/packages-x-gtk2.inc
. $RULES_DIR/tslib.sh
. $SETS_DIR/packages-xorg-xserver.inc
. $SETS_DIR/packages-xorg-drivers.inc
. $SETS_DIR/packages-xorg-apps.inc
. $SETS_DIR/packages-xorg-fonts.inc

#. $SETS_DIR/packages-emulators.inc

#. $SETS_DIR/packages-x-apps.inc
. $RULES_DIR/openbox.sh
. $RULES_DIR/xmodmap.sh

. $SETS_DIR/packages-hal.inc

. $SETS_DIR/packages-x-lxde.inc

#. $SETS_DIR/packages-x-office.inc

. $RULES_DIR/imlib2.sh
. $RULES_DIR/giblib.sh
. $RULES_DIR/scrot.sh

. $RULES_DIR/kbd.sh
. $RULES_DIR/host_lzo.sh
. $RULES_DIR/host_mtd-utils.sh
. $BSP_RULES_DIR/zaurus_custom.sh
. $BSP_RULES_DIR/create_ubifs.sh
