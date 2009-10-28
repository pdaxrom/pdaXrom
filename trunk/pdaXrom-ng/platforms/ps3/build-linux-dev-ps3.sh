#!/bin/bash

ISOIMAGE_NAME=pdaXrom-ng-dev-ps3

TARGET_ARCH="powerpc-ps3-linux"
TOOLCHAIN_PREFIX="/opt/${TARGET_ARCH}/toolchain"
TOOLCHAIN_SYSROOT="/opt/${TARGET_ARCH}/sysroot"

KERNEL_VERSION="2.6.31"
KERNEL_CONFIG=ps3_kernel_2.6.31
TARGET_VENDOR_PATCH=ps3

CROSS_OPT_ARCH="-mtune=cell -mcpu=cell -maltivec"
#CROSS_OPT_CFLAGS="-O3"
#CROSS_OPT_CXXFLAGS="-O3"

USE_SPLASH="yes"
USE_AUFS2="yes"

. $SETS_DIR/packages-basic.inc
. $SETS_DIR/packages-mmlibs.inc
. $SETS_DIR/packages-libs.inc

. $RULES_DIR/wpa_supplicant.sh

. $SETS_DIR/packages-xorg-xlib.inc
. $SETS_DIR/packages-x-gtk2.inc

. $SETS_DIR/packages-hal.inc

. $SETS_DIR/packages-xorg-xserver.inc

. $RULES_DIR/xf86-input-evdev.sh
. $RULES_DIR/xf86-input-joystick.sh
. $RULES_DIR/xf86-input-keyboard.sh
. $RULES_DIR/xf86-input-mouse.sh
. $RULES_DIR/xf86-video-fbdev.sh

. $SETS_DIR/packages-xorg-apps.inc
. $SETS_DIR/packages-xorg-fonts.inc

. $SETS_DIR/packages-xorg-msttcorefonts.inc

#. $SETS_DIR/packages-emulators.inc

. $SETS_DIR/packages-x-apps.inc

. $SETS_DIR/packages-x-lxde.inc

. $SETS_DIR/packages-x-office.inc

. $SETS_DIR/packages-x-voip.inc

. $SETS_DIR/packages-bluetooth.inc

. $SETS_DIR/packages-x-vkeyboard.inc

. $RULES_DIR/sixaxisdmouse.sh

. $SETS_DIR/packages-gparted.inc

. $SETS_DIR/packages-mc.inc
. $SETS_DIR/packages-devel.inc

. $RULES_DIR/install_locale.sh

. $RULES_DIR/ps3-utils.sh
. $RULES_DIR/spufs.sh
. $RULES_DIR/tweak-ps3.sh

. $SETS_DIR/packages-host-squashfs.inc
. $RULES_DIR/create_initramfs.sh
. $RULES_DIR/create_squashfs.sh
. $RULES_DIR/create_ps3cd.sh
