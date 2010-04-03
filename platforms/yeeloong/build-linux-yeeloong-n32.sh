#!/bin/bash

ISOIMAGE_NAME=pdaXrom-ng-yeelong-8089-n32

TARGET_ARCH="mips64el-ls2f-linux"
TOOLCHAIN_PREFIX="/opt/${TARGET_ARCH}/toolchain"
TOOLCHAIN_SYSROOT="/opt/${TARGET_ARCH}/sysroot"

TARGET_VENDOR_PATCH=ls2f

KERNEL_VERSION="2.6.32"
KERNEL_CONFIG=yeeloong2f_2.6.32

CROSS_OPT_ARCH="-march=loongson2f -mtune=loongson2f"
#CROSS_OPT_CFLAGS="-O3"
#CROSS_OPT_CXXFLAGS="-O3"

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

. $RULES_DIR/install_locale.sh

#. $RULES_DIR/fnkey-yeeloong2f.sh

. $RULES_DIR/tweak-yeelong2f.sh

. $SETS_DIR/packages-host-squashfs.inc
. $RULES_DIR/create_initramfs.sh
. $RULES_DIR/create_squashfs.sh

. $RULES_DIR/create_lemote.sh
