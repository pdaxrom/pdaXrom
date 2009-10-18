#!/bin/bash

ISOIMAGE_NAME=pdaXrom-ng-dev-epc700

TARGET_ARCH="mipsel-jz-linux"
TOOLCHAIN_PREFIX="/opt/${TARGET_ARCH}/toolchain"
TOOLCHAIN_SYSROOT="/opt/${TARGET_ARCH}/sysroot"

KERNEL_VERSION="2.6.24.3"
KERNEL_CONFIG=epc700_kernel_2.6.24

TARGET_VENDOR_PATCH=jz
TARGET_KERNEL_IMAGE=uImage

TARGET_GCC_VERSION=4.3.2

. ./sets/packages-basic.inc
. ./sets/packages-acpi.inc
. ./sets/packages-mmlibs.inc
. ./sets/packages-libs.inc

. $RULES_DIR/wpa_supplicant.sh

. ./sets/packages-xorg-xlib.inc
. ./sets/packages-x-gtk2.inc

. ./sets/packages-hal.inc

. ./sets/packages-xorg-xserver.inc

. $RULES_DIR/xf86-input-evdev.sh
. $RULES_DIR/xf86-input-joystick.sh
. $RULES_DIR/xf86-input-keyboard.sh
. $RULES_DIR/xf86-input-mouse.sh
. $RULES_DIR/xf86-input-synaptics.sh
. $RULES_DIR/xf86-video-fbdev.sh
. $RULES_DIR/xf86-video-v4l.sh

. ./sets/packages-xorg-apps.inc
. ./sets/packages-xorg-fonts.inc

. ./sets/packages-xorg-msttcorefonts.inc

#. ./sets/packages-emulators.inc

. ./sets/packages-x-apps.inc

. ./sets/packages-x-lxde.inc

. ./sets/packages-x-office.inc

. ./sets/packages-x-voip.inc

. ./sets/packages-gparted.inc

. ./sets/packages-mc.inc
. ./sets/packages-devel.inc

. $RULES_DIR/install_locale.sh

. $RULES_DIR/tweak-epc700.sh

SQUASHFS_LZMA=no

. ./sets/packages-host-squashfs.inc
. $RULES_DIR/create_initramfs.sh
. $RULES_DIR/create_squashfs.sh

. $RULES_DIR/create_epc700.sh
