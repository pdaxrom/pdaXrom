#!/bin/bash

TARGET_ARCH="armel-linux-gnueabi"
TOOLCHAIN_PREFIX="/opt/${TARGET_ARCH}/toolchain"
TOOLCHAIN_SYSROOT="/opt/${TARGET_ARCH}/sysroot"

KERNEL_VERSION="2.6.29.1"
KERNEL_CONFIG=akita_kernel_2.6.29.1
TARGET_VENDOR_PATCH=akita

. $SETS_DIR/packages-basic.inc
. $SETS_DIR/packages-mmlibs.inc
. $SETS_DIR/packages-libs.inc

. $SETS_DIR/packages-xorg-xlib.inc
. $SETS_DIR/packages-x-gtk2.inc
. $SETS_DIR/packages-xorg-xserver.inc
. $SETS_DIR/packages-xorg-drivers.inc
. $SETS_DIR/packages-xorg-apps.inc
. $SETS_DIR/packages-xorg-fonts.inc

#. $SETS_DIR/packages-emulators.inc

. $SETS_DIR/packages-x-apps.inc

. $SETS_DIR/packages-hal.inc

. $SETS_DIR/packages-x-lxde.inc

. $SETS_DIR/packages-x-office.inc

. $SETS_DIR/packages-host-squashfs.inc
. $RULES_DIR/create_squashfs.sh
