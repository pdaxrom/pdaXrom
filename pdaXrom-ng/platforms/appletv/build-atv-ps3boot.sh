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
. $RULES_DIR/gdisk.sh

cp -f ${BSP_DIR}/README ${ROOTFS_DIR}/home/root/
cp -f ${BSP_SRC_DIR}/build-usbpen.sh ${ROOTFS_DIR}/home/root/
chmod 755 ${ROOTFS_DIR}/home/root/build-usbpen.sh
sed -i -e "s|@PARTED@|/usr/sbin/parted|" ${ROOTFS_DIR}/home/root/build-usbpen.sh
sed -i -e "s|@PPROBE@|/usr/sbin/partprobe|" ${ROOTFS_DIR}/home/root/build-usbpen.sh
sed -i -e "s|@MKFSHFS@|/sbin/mkfs.hfsplus|" ${ROOTFS_DIR}/home/root/build-usbpen.sh

# we don't use c++ here :) but gdisk ;)
#rm -f $ROOTFS_DIR/usr/lib/libstdc++.so*

. $BSP_RULES_DIR/host_parted.sh
. $BSP_RULES_DIR/host_diskdev-cmds.sh
. $SETS_DIR/packages-host-squashfs.inc
. $RULES_DIR/create_squashfs.sh
. $BSP_RULES_DIR/atv-bootloader.sh
. $BSP_RULES_DIR/build_atv_archive.sh

cp -f ${BSP_SRC_DIR}/build-usbpen.sh ${IMAGES_DIR}/
chmod 755 ${IMAGES_DIR}/build-usbpen.sh
sed -i -e "s|@PARTED@|${HOST_BIN_DIR}/sbin/parted|" ${IMAGES_DIR}/build-usbpen.sh
sed -i -e "s|@PPROBE@|${HOST_BIN_DIR}/sbin/partprobe|" ${IMAGES_DIR}/build-usbpen.sh
sed -i -e "s|@MKFSHFS@|${HOST_BIN_DIR}/sbin/mkfs.hfsplus|" ${IMAGES_DIR}/build-usbpen.sh

. $RULES_DIR/host_syslinux.sh
. $RULES_DIR/create_x86cd.sh
