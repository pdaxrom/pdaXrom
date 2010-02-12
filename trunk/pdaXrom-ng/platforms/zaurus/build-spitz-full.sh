#!/bin/bash

if [ "x$TARGET_ARCH" = "x" ]; then
TARGET_ARCH="armel-linux-gnueabi"
fi

TOOLCHAIN_PREFIX="/opt/${TARGET_ARCH}/toolchain"
TOOLCHAIN_SYSROOT="/opt/${TARGET_ARCH}/sysroot"

TARGET_VENDOR_PATCH="zaurus"
TARGET_BUILD="spitz"
KERNEL_VERSION="2.6.32"
KERNEL_CONFIG=akita_kernel_2.6.32_full
U_BOOT_CONFIG=akita
U_BOOT_VERSION=2006-04-18-1106
ENABLE_TSLIB="yes"
ENABLE_HAL="no"
USE_LOGINMANAGER="yes"

. $SETS_DIR/packages-basic.inc
. $RULES_DIR/host_e2fsprogs.sh
. $SETS_DIR/packages-mmlibs.inc
. $SETS_DIR/packages-libs.inc

. $SETS_DIR/packages-acpi.inc
. $RULES_DIR/wpa_supplicant.sh
. $RULES_DIR/e2fsprogs.sh

. $SETS_DIR/packages-xorg-xlib.inc
. $SETS_DIR/packages-x-gtk2.inc
. $RULES_DIR/tslib.sh
. $SETS_DIR/packages-xorg-xserver.inc
. $SETS_DIR/packages-xorg-drivers.inc
. $SETS_DIR/packages-xorg-apps.inc
. $SETS_DIR/packages-xorg-fonts.inc

. $RULES_DIR/openbox.sh
. $RULES_DIR/xmodmap.sh
. $SETS_DIR/packages-x-lxde.inc

. $SETS_DIR/packages-gconf.inc

#
# Firefox 3.5
#
. $RULES_DIR/sqlite.sh
. $RULES_DIR/libogg.sh
. $RULES_DIR/libvorbis.sh
. $RULES_DIR/host_findutils.sh
. $RULES_DIR/host_glib2.sh
. $RULES_DIR/host_libIDL.sh
. $RULES_DIR/libIDL.sh
. $RULES_DIR/firefox-3.5.sh

. $RULES_DIR/target-bash.sh
. $RULES_DIR/slim.sh

# Minimal X display lock program
. $RULES_DIR/xtrlock.sh

#
# xchat
#
. $RULES_DIR/libsexy.sh
. $RULES_DIR/xchat.sh

#
# transmission
#
. $RULES_DIR/curl.sh
. $RULES_DIR/transmission.sh

#
# mplayer
#
. $RULES_DIR/SDL.sh
. $RULES_DIR/libogg.sh
. $RULES_DIR/libvorbis.sh
. $RULES_DIR/speex.sh
#. $RULES_DIR/libtheora.sh
. $RULES_DIR/libv4l.sh
. $RULES_DIR/mplayer.sh
. $RULES_DIR/clearplayer.sh

#
# vlc
#
if [ "$USE_VLC_PLAYER" = "yes" ]; then
. $RULES_DIR/SDL.sh
. $RULES_DIR/libogg.sh
. $RULES_DIR/libvorbis.sh
. $RULES_DIR/speex.sh
#. $RULES_DIR/libtheora.sh
. $RULES_DIR/libv4l.sh
. $RULES_DIR/libmad.sh
. $RULES_DIR/SDL_image.sh
. $RULES_DIR/a52dec.sh
. $RULES_DIR/libmpeg2.sh
. $RULES_DIR/libmtp.sh
#. $RULES_DIR/live555.sh
. $RULES_DIR/zvbi.sh
. $RULES_DIR/libdvbpsi5.sh
. $RULES_DIR/libcddb.sh
. $RULES_DIR/libcdio.sh
. $RULES_DIR/popt.sh
. $RULES_DIR/vcdimager.sh
. $RULES_DIR/libupnp.sh
. $RULES_DIR/host_yasm.sh
. $RULES_DIR/x264-snapshot.sh
. $RULES_DIR/libdvdcss.sh
. $RULES_DIR/libdvdread.sh
. $RULES_DIR/libdvdnav.sh
. $RULES_DIR/taglib.sh
. $RULES_DIR/libproxy.sh
. $RULES_DIR/flac.sh
. $RULES_DIR/readline.sh
. $RULES_DIR/lua.sh
. $RULES_DIR/libfribidi.sh
. $RULES_DIR/qt-all-opensource-src.sh
. $RULES_DIR/vlc.sh

#
# Arora
#
#. $RULES_DIR/arora.sh
fi


#
# Texteditor
#
. $RULES_DIR/leafpad.sh

#
# Image viewer
#
. $RULES_DIR/gpicview.sh

#
# Archiver
#
. $RULES_DIR/unzip.sh
. $RULES_DIR/zip.sh
. $RULES_DIR/unrar.sh
. $RULES_DIR/xarchiver.sh



#. $SETS_DIR/packages-x-office.inc
#. $SETS_DIR/packages-emulators.inc
#. $SETS_DIR/packages-hal.inc
#. $SETS_DIR/packages-x-apps.inc

. $RULES_DIR/imlib2.sh
. $RULES_DIR/giblib.sh
. $RULES_DIR/scrot.sh

. $RULES_DIR/kbd.sh
. $RULES_DIR/host_lzo.sh
. $RULES_DIR/host_mtd-utils.sh
. $BSP_RULES_DIR/spitz_custom.sh
. $BSP_RULES_DIR/create_ubifs.sh
