#!/bin/bash

TARGET_ARCH="i686-linux"
TOOLCHAIN_PREFIX="/opt/${TARGET_ARCH}/toolchain"
TOOLCHAIN_SYSROOT="/opt/${TARGET_ARCH}/sysroot"

KERNEL_VERSION="2.6.28"
KERNEL_CONFIG=i686-kernel-2.6.28

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

. ./packages-hal.inc

. ./packages-x-lxde.inc

. ./packages-devel.inc

. $RULES_DIR/tweak-i686.sh
. $RULES_DIR/create_initramfs.sh
. $RULES_DIR/host_syslinux.sh
. $RULES_DIR/create_x86cd.sh