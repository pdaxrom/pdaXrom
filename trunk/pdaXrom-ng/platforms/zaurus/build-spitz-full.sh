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

. $SETS_DIR/packages-xorg-xlib.inc
. $SETS_DIR/packages-x-gtk2.inc

. $SETS_DIR/packages-hal.inc
. $SETS_DIR/packages-xorg-xserver.inc

. $RULES_DIR/xf86-input-evdev.sh
. $RULES_DIR/xf86-input-keyboard.sh
. $RULES_DIR/xf86-input-mouse.sh
. $RULES_DIR/xf86-video-fbdev.sh
. $SETS_DIR/packages-xorg-apps.inc
. $SETS_DIR/packages-xorg-fonts.inc

. $SETS_DIR/packages-xorg-msttcorefonts.inc

. $SETS_DIR/packages-x-lxde.inc

. $RULES_DIR/kbd.sh
. $RULES_DIR/host_lzo.sh
. $RULES_DIR/host_mtd-utils.sh
. $BSP_RULES_DIR/zaurus_custom.sh
. $BSP_RULES_DIR/create_jffs2.sh
