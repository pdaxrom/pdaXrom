#!/bin/bash

TARGET_ARCH="armel-linux-gnueabi"
TOOLCHAIN_PREFIX="/opt/${TARGET_ARCH}/toolchain"
TOOLCHAIN_SYSROOT="/opt/${TARGET_ARCH}/sysroot"

KERNEL_VERSION="2.6.29.1"
KERNEL_CONFIG=akita_kernel_2.6.29.1

. ./sets/packages-basic.inc
. ./sets/packages-mmlibs.inc
. ./sets/packages-libs.inc

. ./sets/packages-xorg-xlib.inc
. ./sets/packages-x-gtk2.inc
. ./sets/packages-xorg-xserver.inc
. ./sets/packages-xorg-drivers.inc
. ./sets/packages-xorg-apps.inc
. ./sets/packages-xorg-fonts.inc

#. ./sets/packages-emulators.inc

. ./sets/packages-x-apps.inc

. ./sets/packages-hal.inc

. ./sets/packages-x-lxde.inc

. ./sets/packages-x-office.inc

. ./sets/packages-devel.inc

. ./sets/packages-host-squashfs.inc
. $RULES_DIR/create_squashfs.sh