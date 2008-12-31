#!/bin/bash

TARGET_ARCH="powerpc-linux"
TOOLCHAIN_PREFIX="/opt/${TARGET_ARCH}/toolchain"
TOOLCHAIN_SYSROOT="/opt/${TARGET_ARCH}/sysroot"
CROSS=${TARGET_ARCH}-
GLIBC_DIR="${TOOLCHAIN_SYSROOT}/lib"

KERNEL_CONFIG=ps3_kernel_config

. ./packages-basic.inc
. ./packages-mmlibs.inc
. ./packages-libs.inc

. ./packages-xorg-xlib.inc
. ./packages-xorg-xserver.inc
. ./packages-xorg-drivers.inc
. ./packages-xorg-apps.inc
. ./packages-xorg-fonts.inc

#. ./packages-emulators.inc

. ./packages-x-apps.inc

. ./packages-x-lxde.inc

. ./packages-devel.inc

. $RULES_DIR/ps3-utils.sh
. $RULES_DIR/tweak-ps3.sh
. $RULES_DIR/create_initramfs.sh
. $RULES_DIR/create_ps3cd.sh
