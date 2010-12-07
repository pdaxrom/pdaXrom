#!/bin/bash

ISOIMAGE_NAME="i686-emubox"
FAT_TITLE="i686 EmuBOX"
FATIMAGE_NAME="i686-emubox"

BOOTFAT_IMAGE_SIZE=250

TARGET_ARCH="i686-linux"
TOOLCHAIN_PREFIX="/opt/${TARGET_ARCH}/toolchain"
TOOLCHAIN_SYSROOT="/opt/${TARGET_ARCH}/sysroot"

KERNEL_VERSION="2.6.36"
KERNEL_CONFIG=i686-kernel-2.6.36

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

. $RULES_DIR/DirectFB.sh
. $RULES_DIR/SDL-directfb.sh

. $RULES_DIR/unzip.sh
. $RULES_DIR/zip.sh
. $RULES_DIR/unrar.sh
. $RULES_DIR/nano.sh

. $RULES_DIR/dropbear.sh

. $SETS_DIR/packages-netsurf.inc

. $RULES_DIR/dosbox.sh

. $RULES_DIR/SDL_image.sh
. $RULES_DIR/pyldin601.sh

. $RULES_DIR/vMac.sh
. $RULES_DIR/basilisk2.sh
. $RULES_DIR/SheepShaver.sh

#. $RULES_DIR/gdb.sh
#. $RULES_DIR/strace.sh

#. $SETS_DIR/packages-bluez3.inc
#. $RULES_DIR/sixaxisdmouse.sh

. $RULES_DIR/minimount-svn.sh
. $RULES_DIR/915resolution.sh
. $RULES_DIR/v86d.sh

. $RULES_DIR/tweak-i686.sh

. $SETS_DIR/packages-host-squashfs4.inc
. $RULES_DIR/create_squashfs4.sh
. $RULES_DIR/host_syslinux.sh
. $RULES_DIR/create_x86cd.sh
. $RULES_DIR/host_makebootfat.sh
. $RULES_DIR/create_bootfat.sh
