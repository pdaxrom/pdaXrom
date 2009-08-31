#!/bin/bash

TARGET_ARCH="armel-linux-uclibc"
TOOLCHAIN_PREFIX="/opt/${TARGET_ARCH}/toolchain"
TOOLCHAIN_SYSROOT="/opt/${TARGET_ARCH}/sysroot"

KERNEL_VERSION="2.6.10"
KERNEL_CONFIG=archos605_kernel_2.6.10

TARGET_VENDOR_PATCH=archos
TARGET_KERNEL_IMAGE=zImage

KERNEL_OLDCONFIG_ENABLED=no

./generic/cpio-archos605/archos605.sh

. ./sets/packages-basic.inc
# . ./sets/packages-mmlibs.inc
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

#. $RULES_DIR/tweak-stb610.sh
#. $RULES_DIR/create_initramfs.sh
#. ./sets/packages-host-mtd-utils.inc
#. $RULES_DIR/create_jffs2.sh
