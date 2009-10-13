#!/bin/bash

ISOIMAGE_NAME="pcio-client-yeeloong2f"

TARGET_ARCH="mipsel-ls2f-linux"
TOOLCHAIN_PREFIX="/opt/${TARGET_ARCH}/toolchain"
TOOLCHAIN_SYSROOT="/opt/${TARGET_ARCH}/sysroot"

TARGET_VENDOR_PATCH=ls2f

KERNEL_VERSION="2.6.31"
KERNEL_CONFIG=yeeloong2f_2.6.31

USE_SPLASH="yes"

case $1 in
prod*)
    echo "Production client"
    PCIO_HOSTS="200.170.196.227"
    ;;
*)
    echo "Devnode client"
    ISOIMAGE_NAME="pcio-client-dev-yeeloong2f"
    ;;
esac

. ./sets/packages-basic.inc
. ./sets/packages-mmlibs.inc
. ./sets/packages-libs.inc

. ./sets/packages-xorg-xlib.inc
. ./sets/packages-xorg-xserver.inc
. ./sets/packages-xorg-drivers.inc
. $RULES_DIR/xf86-video-siliconmotion.sh
. $RULES_DIR/xf86-video-v4l.sh
. ./sets/packages-xorg-apps.inc
. ./sets/packages-xorg-fonts.inc
. ./sets/packages-xorg-msttcorefonts.inc

. ./sets/packages-pcio-client.sh

. ./sets/packages-hal.inc
. $RULES_DIR/boolstuff.sh
. $RULES_DIR/halevt.sh

. $RULES_DIR/tweak-yeelong2f.sh

. ./sets/packages-host-squashfs.inc
. $RULES_DIR/create_initramfs.sh
. $RULES_DIR/create_squashfs.sh
. $RULES_DIR/create_lemote.sh
