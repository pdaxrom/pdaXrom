#!/bin/bash

TARGET_ARCH="powerpc-ps3-linux-uclibc"
TOOLCHAIN_PREFIX="/opt/${TARGET_ARCH}/toolchain"
TOOLCHAIN_SYSROOT="/opt/${TARGET_ARCH}/sysroot"

KERNEL_VERSION="2.6.31"
KERNEL_CONFIG=ps3_kernel_2.6.31
TARGET_VENDOR_PATCH=ps3

. $SETS_DIR/packages-basic.inc

. $SETS_DIR/packages-bluez3.inc

. $RULES_DIR/bzip2.sh
. $RULES_DIR/libjpeg.sh
. $RULES_DIR/libpng.sh
. $RULES_DIR/uuid.sh
. $RULES_DIR/libiconv.sh
. $RULES_DIR/expat.sh
. $RULES_DIR/libxml2.sh
. $RULES_DIR/freetype.sh
. $RULES_DIR/fontconfig.sh
. $RULES_DIR/host_glib2.sh
. $RULES_DIR/host_gettext.sh
. $RULES_DIR/gettext.sh
. $RULES_DIR/glib2.sh

. $RULES_DIR/atk.sh
. $RULES_DIR/DirectFB.sh

. $RULES_DIR/pixman.sh
. $RULES_DIR/cairo-directfb.sh
. $RULES_DIR/pango-directfb.sh
. $RULES_DIR/gtk2-directfb.sh

#
# icons set
#
. $RULES_DIR/host_intltool.sh
. $RULES_DIR/host_icon-naming-utils.sh
. $RULES_DIR/gnome-icon-theme.sh
. $RULES_DIR/host_shared-mime-info.sh
. $RULES_DIR/shared-mime-info.sh

. $SETS_DIR/packages-xorg-msttcorefonts.inc

#
# firefox
#
#. $RULES_DIR/host_findutils.sh
#. $RULES_DIR/host_libIDL.sh
#. $RULES_DIR/libIDL.sh
#. $RULES_DIR/firefox-directfb.sh

#
# webkit
#
. $RULES_DIR/sqlite.sh
. $RULES_DIR/libtasn1.sh
. $RULES_DIR/libgpg-error.sh
. $RULES_DIR/libgcrypt.sh
. $RULES_DIR/gnutls.sh
. $RULES_DIR/curl.sh
. $RULES_DIR/libxslt.sh
. $RULES_DIR/host_icu4c.sh
. $RULES_DIR/icu4c.sh
. $RULES_DIR/libsoup.sh
. $RULES_DIR/WebKit-directfb.sh

# midori
#
#. $RULES_DIR/libunique.sh
. $RULES_DIR/midori.sh

. $RULES_DIR/ps3-utils.sh
. $RULES_DIR/spufs.sh
. $RULES_DIR/tweak-ps3.sh

. $SETS_DIR/packages-host-squashfs.inc
. $RULES_DIR/create_squashfs.sh
. $RULES_DIR/create_ps3cd.sh
