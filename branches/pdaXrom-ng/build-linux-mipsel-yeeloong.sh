#!/bin/bash

ISOIMAGE_NAME=pdaXrom-ng-yeelong-8089

TARGET_ARCH="mipsel-ls2f-linux"
TOOLCHAIN_PREFIX="/opt/${TARGET_ARCH}/toolchain"
TOOLCHAIN_SYSROOT="/opt/${TARGET_ARCH}/sysroot"

TARGET_VENDOR_PATCH=ls2f

KERNEL_VERSION="2.6.30.2"
KERNEL_CONFIG=yeeloong2f_2.6.30.2

SQUASHFS_LZMA=no

. ./sets/packages-basic.inc
. ./sets/packages-acpi.inc
. ./sets/packages-mmlibs.inc
. ./sets/packages-libs.inc

. $RULES_DIR/wpa_supplicant.sh

. ./sets/packages-xorg-xlib.inc
. ./sets/packages-x-gtk2.inc
. ./sets/packages-xorg-xserver.inc
#. ./sets/packages-xorg-drivers.inc

. $RULES_DIR/xf86-input-evdev.sh
. $RULES_DIR/xf86-input-joystick.sh
. $RULES_DIR/xf86-input-keyboard.sh
. $RULES_DIR/xf86-input-mouse.sh
. $RULES_DIR/xf86-input-synaptics.sh
. $RULES_DIR/xf86-video-fbdev.sh
. $RULES_DIR/xf86-video-siliconmotion.sh
. $RULES_DIR/xf86-video-v4l.sh

. ./sets/packages-xorg-apps.inc
. ./sets/packages-xorg-fonts.inc

. ./sets/packages-xorg-msttcorefonts.inc

#. ./sets/packages-emulators.inc

. ./sets/packages-x-apps.inc

. ./sets/packages-hal.inc

. ./sets/packages-x-lxde.inc

. ./sets/packages-x-office.inc

. ./sets/packages-x-voip.inc

. ./sets/packages-devel.inc

. $RULES_DIR/tweak-yeelong2f.sh

. ./sets/packages-host-squashfs4.inc
. $RULES_DIR/create_initramfs.sh
. $RULES_DIR/create_squashfs.sh

. $RULES_DIR/create_lemote.sh
