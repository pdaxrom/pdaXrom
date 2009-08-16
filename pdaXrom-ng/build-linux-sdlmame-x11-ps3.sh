#!/bin/bash

ISOIMAGE_NAME="sdlmame-x11-ps3"

TARGET_ARCH="powerpc-ps3-linux"
TOOLCHAIN_PREFIX="/opt/${TARGET_ARCH}/toolchain"
TOOLCHAIN_SYSROOT="/opt/${TARGET_ARCH}/sysroot"

KERNEL_VERSION="2.6.30"
KERNEL_CONFIG=ps3_kernel_2.6.30
TARGET_VENDOR_PATCH=ps3

. ./sets/packages-basic.inc
. ./sets/packages-mmlibs.inc
. ./sets/packages-libs.inc

. ./sets/packages-xorg-xlib.inc
. ./sets/packages-xorg-xserver.inc
. ./sets/packages-xorg-drivers.inc
. ./sets/packages-xorg-apps.inc
. ./sets/packages-xorg-fonts.inc
. ./sets/packages-xorg-msttcorefonts.inc

. $RULES_DIR/unzip.sh
. $RULES_DIR/zip.sh
. $RULES_DIR/unrar.sh

. $RULES_DIR/nano.sh

. ./sets/packages-hal.inc
. $RULES_DIR/boolstuff.sh
. $RULES_DIR/halevt.sh

. ./sets/packages-emulators.inc

#
# mame scripts
#
test -e $ROOTFS_DIR/usr/bin/qmc2 && $INSTALL -D -m 644 $GENERICFS_DIR/sdlmame/qmc2.ini $ROOTFS_DIR/home/.qmc2/qmc2.ini
test -e $ROOTFS_DIR/usr/bin/sdlmame && $INSTALL -D -m 755 $GENERICFS_DIR/sdlmame/xinitrc.mame $ROOTFS_DIR/etc/X11/xinit/xinitrc

. $RULES_DIR/ps3-utils.sh
. $RULES_DIR/spufs.sh
. $RULES_DIR/tweak-ps3.sh

. ./sets/packages-host-squashfs.inc
. $RULES_DIR/create_initramfs.sh
. $RULES_DIR/create_squashfs.sh
. $RULES_DIR/create_ps3cd.sh
