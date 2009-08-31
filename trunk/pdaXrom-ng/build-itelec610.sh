#!/bin/bash

TARGET_ARCH="armel-linux-gnueabi"
TOOLCHAIN_PREFIX="/opt/${TARGET_ARCH}/toolchain"
TOOLCHAIN_SYSROOT="/opt/${TARGET_ARCH}/sysroot"

KERNEL_VERSION="2.6.28"
KERNEL_CONFIG=itelec610_kernel_2.6.28

TARGET_VENDOR_PATCH=davinci
TARGET_KERNEL_IMAGE=uImage

#TARGET_JFFS2_ERASEBLOCK=16384
#TARGET_JFFS2_PAGESIZE=4096
TARGET_JFFS2_ARGS="-p -n"

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

. $RULES_DIR/tweak-stb610.sh
#. $RULES_DIR/create_initramfs.sh
. ./sets/packages-host-mtd-utils.inc
. $RULES_DIR/create_jffs2.sh
