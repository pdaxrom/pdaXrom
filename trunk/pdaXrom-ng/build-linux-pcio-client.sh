#!/bin/bash

ISOIMAGE_NAME="pcio-client-i686"

TARGET_ARCH="i686-linux"
TOOLCHAIN_PREFIX="/opt/${TARGET_ARCH}/toolchain"
TOOLCHAIN_SYSROOT="/opt/${TARGET_ARCH}/sysroot"

KERNEL_VERSION="2.6.30"
KERNEL_CONFIG=i686-kernel-2.6.30

USE_SPLASH="yes"

case $1 in
prod*)
    echo "Production client"
    PCIO_HOSTS="200.170.196.227"
    ;;
dev*)
    echo "Devnode client"
    ISOIMAGE_NAME="pcio-client-dev-i686"
    ;;
esac

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

. ./sets/packages-hal.inc
. $RULES_DIR/boolstuff.sh
. $RULES_DIR/halevt.sh

. $RULES_DIR/tweak-i686.sh

. ./sets/packages-host-squashfs.inc

. $RULES_DIR/create_squashfs.sh
. $RULES_DIR/host_syslinux.sh
. $RULES_DIR/create_x86cd.sh
