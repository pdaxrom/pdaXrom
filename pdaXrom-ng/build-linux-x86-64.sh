#!/bin/bash

ISOIMAGE_NAME=pdaXrom-ng-x86-64

TARGET_ARCH="x86_64-linux"
TOOLCHAIN_PREFIX="/opt/${TARGET_ARCH}/toolchain"
TOOLCHAIN_SYSROOT="/opt/${TARGET_ARCH}/sysroot"

KERNEL_VERSION="2.6.31"
KERNEL_CONFIG=x86_64-kernel-2.6.31

. ./sets/packages-basic.inc

. ./sets/packages-acpi.inc

. ./sets/packages-mmlibs.inc
. ./sets/packages-libs.inc

. $RULES_DIR/wpa_supplicant.sh

. ./sets/packages-xorg-xlib.inc
. ./sets/packages-x-gtk2.inc
. ./sets/packages-xorg-xserver.inc
. ./sets/packages-xorg-drivers.inc
. ./sets/packages-xorg-apps.inc
. ./sets/packages-xorg-fonts.inc

. ./sets/packages-xorg-msttcorefonts.inc

#. ./sets/packages-emulators.inc

. ./sets/packages-x-apps.inc

. ./sets/packages-hal.inc

. ./sets/packages-x-lxde.inc

. ./sets/packages-x-office.inc

. ./sets/packages-x-voip.inc

. ./sets/packages-bluetooth.inc

. ./sets/packages-x-vkeyboard.inc

. ./sets/packages-x-rdp.inc

. $RULES_DIR/install_locale.sh

. $RULES_DIR/tweak-i686.sh

. ./sets/packages-host-squashfs.inc
. $RULES_DIR/create_squashfs.sh
. $RULES_DIR/host_syslinux.sh
. $RULES_DIR/create_x86cd.sh
