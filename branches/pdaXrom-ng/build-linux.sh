#!/bin/bash

TARGET_ARCH="i686-linux"
TOOLCHAIN_PREFIX="/opt/${TARGET_ARCH}/toolchain"
TOOLCHAIN_SYSROOT="/opt/${TARGET_ARCH}/sysroot"
CROSS=i686-linux-
GLIBC_DIR="${TOOLCHAIN_SYSROOT}/lib"

KERNEL_CONFIG=i686_ubuntu_kernel_config

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

. $RULES_DIR/tweak-i686.sh
. $RULES_DIR/create_initramfs.sh
. $RULES_DIR/host_syslinux.sh
. $RULES_DIR/create_x86cd.sh
