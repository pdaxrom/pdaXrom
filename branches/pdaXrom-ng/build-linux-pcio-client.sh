#!/bin/bash

ISOIMAGE_NAME="pcio-client-i686"

TARGET_ARCH="i686-linux"
TOOLCHAIN_PREFIX="/opt/${TARGET_ARCH}/toolchain"
TOOLCHAIN_SYSROOT="/opt/${TARGET_ARCH}/sysroot"

KERNEL_VERSION="2.6.30"
KERNEL_CONFIG=i686-kernel-2.6.30
SQUASHFS_LZMA=no

. ./sets/packages-basic.inc
. ./sets/packages-mmlibs.inc
. ./sets/packages-libs.inc

. ./sets/packages-xorg-xlib.inc
. ./sets/packages-xorg-xserver.inc
. ./sets/packages-xorg-drivers.inc
. ./sets/packages-xorg-apps.inc
. ./sets/packages-xorg-fonts.inc
. ./sets/packages-xorg-msttcorefonts.inc

. ./sets/packages-pcio-client.sh

. $RULES_DIR/tweak-i686.sh

echo "---- $PWD"

. ./sets/packages-host-squashfs4.inc

echo "---- $PWD"

. $RULES_DIR/create_squashfs.sh
. $RULES_DIR/host_syslinux.sh
. $RULES_DIR/create_x86cd.sh
