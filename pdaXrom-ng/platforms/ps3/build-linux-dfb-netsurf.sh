#!/bin/bash

ISOIMAGE_NAME="netsurf-dfb-ps3"

TARGET_ARCH="powerpc-ps3-linux"
TOOLCHAIN_PREFIX="/opt/${TARGET_ARCH}/toolchain"
TOOLCHAIN_SYSROOT="/opt/${TARGET_ARCH}/sysroot"

KERNEL_VERSION="2.6.32"
KERNEL_CONFIG=ps3_kernel_2.6.32
TARGET_VENDOR_PATCH=ps3

LIBC_GCONV_MODULES="CP1252.so"

. ./rules/core.sh

. $RULES_DIR/host_pkgconfig.sh
. $RULES_DIR/host_findutils.sh
. $RULES_DIR/host_cdrkit.sh
. $RULES_DIR/host_module-init-tools.sh

. $RULES_DIR/create_root.sh
. $RULES_DIR/linux_kernel.sh
. $RULES_DIR/busybox.sh
. $RULES_DIR/host_ncurses.sh
. $RULES_DIR/ncurses.sh
. $RULES_DIR/module-init-tools.sh
. $RULES_DIR/udev.sh
. $RULES_DIR/wireless_tools.sh
. $RULES_DIR/dhcpcd.sh
. $RULES_DIR/install_libc.sh
. $RULES_DIR/zlib.sh
. $RULES_DIR/figlet.sh

. $RULES_DIR/alsa-lib.sh
. $RULES_DIR/alsa-utils.sh

. $RULES_DIR/bzip2.sh
. $RULES_DIR/libjpeg.sh
. $RULES_DIR/libpng.sh
. $RULES_DIR/uuid.sh
. $RULES_DIR/openssl.sh
. $RULES_DIR/expat.sh
. $RULES_DIR/freetype.sh
. $RULES_DIR/fontconfig.sh
. $RULES_DIR/libxml2.sh
. $RULES_DIR/host_gettext.sh
. $RULES_DIR/host_glib2.sh
. $RULES_DIR/glib2.sh

. $RULES_DIR/atk.sh
. $RULES_DIR/DirectFB.sh
. $RULES_DIR/SDL-directfb.sh

. $RULES_DIR/unzip.sh
. $RULES_DIR/zip.sh
. $RULES_DIR/unrar.sh
. $RULES_DIR/nano.sh

. $SETS_DIR/packages-hal.inc
. $RULES_DIR/boolstuff.sh
. $RULES_DIR/halevt.sh

. $SETS_DIR/packages-netsurf.inc

. $RULES_DIR/dosbox.sh

. $SETS_DIR/packages-bluetooth.inc
. $RULES_DIR/sixaxisdmouse.sh

. $RULES_DIR/ps3-utils.sh
. $RULES_DIR/spufs.sh
. $RULES_DIR/tweak-ps3.sh

. $SETS_DIR/packages-host-squashfs.inc
. $RULES_DIR/create_squashfs.sh
. $RULES_DIR/create_ps3cd.sh
