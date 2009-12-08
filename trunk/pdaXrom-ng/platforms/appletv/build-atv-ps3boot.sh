#!/bin/bash

ISOIMAGE_NAME=atv-ps3boot

TARGET_ARCH="i686-linux-uclibc"
TOOLCHAIN_PREFIX="/opt/${TARGET_ARCH}/toolchain"
TOOLCHAIN_SYSROOT="/opt/${TARGET_ARCH}/sysroot"

DARWIN_TOOLCHAINS_PREFIX="/opt/i686-apple-darwin10/toolchain/bin/i686-apple-darwin10-"

KERNEL_VERSION="2.6.32"
KERNEL_CONFIG=kernel-2.6.32

TARGET_KERNEL_IMAGE=bzImage

. ./rules/core.sh

. $RULES_DIR/host_pkgconfig.sh
. $RULES_DIR/host_findutils.sh
. $RULES_DIR/create_root.sh
. $RULES_DIR/linux_kernel.sh
. $RULES_DIR/busybox.sh
. $RULES_DIR/udev.sh
. $RULES_DIR/wireless_tools.sh
. $RULES_DIR/dhcpcd.sh
. $RULES_DIR/install_libc.sh
. $RULES_DIR/zlib.sh
. $RULES_DIR/dropbear.sh
. $RULES_DIR/figlet.sh
. $RULES_DIR/kexec-tools.sh
. $RULES_DIR/libjpeg.sh
. $RULES_DIR/libpng.sh
. $RULES_DIR/freetype.sh
. $RULES_DIR/ps3boot.sh

. $RULES_DIR/openssl.sh
. $BSP_RULES_DIR/diskdev-cmds.sh
. $RULES_DIR/e2fsprogs.sh
. $BSP_RULES_DIR/parted.sh

# we don't use c++ here :)
rm -f $ROOTFS_DIR/usr/lib/libstdc++.so*

. $BSP_RULES_DIR/host_parted.sh
. $BSP_RULES_DIR/host_diskdev-cmds.sh
. $SETS_DIR/packages-host-squashfs.inc
. $RULES_DIR/create_squashfs.sh
. $BSP_RULES_DIR/atv-bootloader.sh

. $RULES_DIR/host_syslinux.sh
. $RULES_DIR/create_x86cd.sh
