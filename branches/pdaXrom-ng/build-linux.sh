#!/bin/bash

TARGET_ARCH="i686-linux"
TOOLCHAIN_PREFIX="/opt/${TARGET_ARCH}/toolchain"
TOOLCHAIN_SYSROOT="/opt/${TARGET_ARCH}/sysroot"

KERNEL_VERSION="2.6.29"
KERNEL_CONFIG=i686-kernel-2.6.29
SQUASHFS_LZMA=no

. ./sets/packages-basic.inc
. ./sets/packages-mmlibs.inc
. ./sets/packages-libs.inc

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

. ./sets/packages-bluetooth.inc

. ./sets/packages-devel.inc

. $RULES_DIR/flashplayer-adobe-x86.sh

. $RULES_DIR/tweak-i686.sh

. ./sets/packages-host-squashfs4.inc
. $RULES_DIR/create_squashfs.sh
. $RULES_DIR/host_syslinux.sh
. $RULES_DIR/create_x86cd.sh
