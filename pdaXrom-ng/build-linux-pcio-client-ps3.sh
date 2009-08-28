#!/bin/bash

ISOIMAGE_NAME="pcio-client-ps3"

TARGET_ARCH="powerpc-ps3-linux"
TOOLCHAIN_PREFIX="/opt/${TARGET_ARCH}/toolchain"
TOOLCHAIN_SYSROOT="/opt/${TARGET_ARCH}/sysroot"

KERNEL_VERSION="2.6.30"
KERNEL_CONFIG=ps3_kernel_2.6.30
TARGET_VENDOR_PATCH=ps3

USE_SPLASH="yes"

. ./sets/packages-basic.inc
. ./sets/packages-mmlibs.inc
. ./sets/packages-libs.inc

. ./sets/packages-xorg-xlib.inc
. ./sets/packages-xorg-xserver.inc

. $RULES_DIR/xf86-input-evdev.sh
. $RULES_DIR/xf86-input-joystick.sh
. $RULES_DIR/xf86-input-keyboard.sh
. $RULES_DIR/xf86-input-mouse.sh
. $RULES_DIR/xf86-video-fbdev.sh

. ./sets/packages-xorg-apps.inc
. ./sets/packages-xorg-fonts.inc
. ./sets/packages-xorg-msttcorefonts.inc

. ./sets/packages-pcio-client.sh

. ./sets/packages-hal.inc
. $RULES_DIR/boolstuff.sh
. $RULES_DIR/halevt.sh

. $RULES_DIR/ps3-utils.sh
. $RULES_DIR/spufs.sh
. $RULES_DIR/tweak-ps3.sh

. ./sets/packages-host-squashfs.inc
. $RULES_DIR/create_initramfs.sh
. $RULES_DIR/create_squashfs.sh
. $RULES_DIR/create_ps3cd.sh
