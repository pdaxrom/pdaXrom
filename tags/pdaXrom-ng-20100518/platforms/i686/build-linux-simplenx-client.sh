#!/bin/bash

ISOIMAGE_NAME="simplenx-client-x86"

TARGET_ARCH="i686-linux"
TOOLCHAIN_PREFIX="/opt/${TARGET_ARCH}/toolchain"
TOOLCHAIN_SYSROOT="/opt/${TARGET_ARCH}/sysroot"

KERNEL_VERSION="2.6.32"
KERNEL_CONFIG=i686-kernel-2.6.32

. $SETS_DIR/packages-basic.inc
. $SETS_DIR/packages-mmlibs.inc
. $SETS_DIR/packages-libs.inc

. $SETS_DIR/packages-xorg-xlib.inc
. $SETS_DIR/packages-xorg-xserver.inc
. $SETS_DIR/packages-xorg-drivers.inc
. $SETS_DIR/packages-xorg-apps.inc
. $SETS_DIR/packages-xorg-fonts.inc

. $SETS_DIR/packages-simplenx-client.sh

#. $SETS_DIR/packages-xorg-qt4.inc

. $RULES_DIR/tweak-i686.sh

. $SETS_DIR/packages-host-squashfs.inc

. $RULES_DIR/create_squashfs.sh
. $RULES_DIR/host_syslinux.sh
. $RULES_DIR/create_x86cd.sh
