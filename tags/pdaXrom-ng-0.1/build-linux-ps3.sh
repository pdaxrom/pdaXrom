#!/bin/bash

TARGET_ARCH="powerpc-linux"
TOOLCHAIN_PREFIX="/opt/${TARGET_ARCH}/toolchain"
TOOLCHAIN_SYSROOT="/opt/${TARGET_ARCH}/sysroot"

KERNEL_CONFIG=ps3_kernel_config

. ./sets/packages-basic.inc
. ./sets/packages-mmlibs.inc
. ./sets/packages-libs.inc

. ./sets/packages-xorg-xlib.inc
. ./sets/packages-xorg-xserver.inc
. ./sets/packages-xorg-drivers.inc
. ./sets/packages-xorg-apps.inc
. ./sets/packages-xorg-fonts.inc

#. ./sets/packages-emulators.inc

. ./sets/packages-x-apps.inc

. ./sets/packages-hal.inc

. ./sets/packages-x-lxde.inc

. ./sets/packages-devel.inc

. $RULES_DIR/ps3-utils.sh
. $RULES_DIR/spufs.sh
. $RULES_DIR/tweak-ps3.sh
. $RULES_DIR/create_initramfs.sh
. $RULES_DIR/create_ps3cd.sh
