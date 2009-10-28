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
. $RULES_DIR/xf86-input-joystick.sh
. $RULES_DIR/xf86-input-keyboard.sh
. $RULES_DIR/xf86-input-mouse.sh
. $RULES_DIR/xf86-input-synaptics.sh
. $RULES_DIR/xf86-video-fbdev.sh
. $RULES_DIR/xf86-video-v4l.sh

. $SETS_DIR/packages-xorg-apps.inc
. $SETS_DIR/packages-xorg-fonts.inc

. $SETS_DIR/packages-xorg-msttcorefonts.inc

#. $SETS_DIR/packages-emulators.inc

. $SETS_DIR/packages-x-apps.inc

. $SETS_DIR/packages-x-lxde.inc

. $SETS_DIR/packages-x-office.inc

. $SETS_DIR/packages-x-voip.inc

. $SETS_DIR/packages-gparted.inc

. $SETS_DIR/packages-mc.inc
. $SETS_DIR/packages-devel.inc

. $RULES_DIR/install_locale.sh

. $RULES_DIR/tweak-epc700.sh

SQUASHFS_LZMA=no

. $SETS_DIR/packages-host-squashfs.inc
. $RULES_DIR/create_initramfs.sh
. $RULES_DIR/create_squashfs.sh

. $RULES_DIR/create_epc700.sh
