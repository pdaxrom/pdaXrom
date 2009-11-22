#!/bin/bash

ISOIMAGE_NAME=pdaXrom-ng-dev-yeelong-8089

TARGET_ARCH="mipsel-ls2f-linux"
TOOLCHAIN_PREFIX="/opt/${TARGET_ARCH}/toolchain"
TOOLCHAIN_SYSROOT="/opt/${TARGET_ARCH}/sysroot"

TARGET_GCC_VERSION=4.4.2
TARGET_BINUTILS_VERSION=2.20.51.0.3

TARGET_VENDOR_PATCH=ls2f

KERNEL_VERSION="2.6.31"
KERNEL_CONFIG=yeeloong2f_2.6.31

USE_AUFS2="yes"

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
. $RULES_DIR/xf86-video-siliconmotion.sh
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
. $RULES_DIR/geany.sh

. $RULES_DIR/install_locale.sh

#. $RULES_DIR/fnkey-yeeloong2f.sh

. $RULES_DIR/tweak-yeelong2f.sh

. $SETS_DIR/packages-host-squashfs.inc
. $RULES_DIR/create_initramfs.sh
. $RULES_DIR/create_squashfs.sh

. $RULES_DIR/create_lemote.sh
