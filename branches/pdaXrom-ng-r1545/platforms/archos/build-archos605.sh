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

. $SETS_DIR/packages-basic.inc
# . $SETS_DIR/packages-mmlibs.inc
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

#. $RULES_DIR/tweak-stb610.sh
#. $RULES_DIR/create_initramfs.sh
#. $SETS_DIR/packages-host-mtd-utils.inc
#. $RULES_DIR/create_jffs2.sh
