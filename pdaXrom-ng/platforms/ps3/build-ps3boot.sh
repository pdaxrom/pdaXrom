#!/bin/bash

TARGET_ARCH="powerpc-ps3-linux-uclibc"
TOOLCHAIN_PREFIX="/opt/${TARGET_ARCH}/toolchain"
TOOLCHAIN_SYSROOT="/opt/${TARGET_ARCH}/sysroot"

KERNEL_VERSION="2.6.32"
TARGET_VENDOR_PATCH=ps3

KERNEL_CONFIG=ps3_kboot_bt_2.6.32
BUSYBOX_CONFIG=busybox_config

BLUEZ_UTILS3_BIN_FILES="tools/hciconfig"

. ./rules/core.sh

. $RULES_DIR/host_pkgconfig.sh
. $RULES_DIR/host_findutils.sh
. $RULES_DIR/create_root.sh
. $RULES_DIR/spufs.sh
. $RULES_DIR/linux_kernel.sh
. $RULES_DIR/busybox.sh
. $RULES_DIR/udev.sh
. $RULES_DIR/wireless_tools.sh
. $RULES_DIR/dhcpcd.sh
. $RULES_DIR/install_libc.sh
. $RULES_DIR/zlib.sh
. $RULES_DIR/dropbear.sh
. $RULES_DIR/figlet.sh
. $RULES_DIR/ps3-utils.sh
. $RULES_DIR/kexec-tools2.sh
. $RULES_DIR/libjpeg.sh
. $RULES_DIR/libpng.sh
. $RULES_DIR/freetype.sh
. $RULES_DIR/ps3boot.sh

. $SETS_DIR/packages-bluez3.inc
. $RULES_DIR/sixaxisd.sh

# we don't use c++ here :)
rm -f $ROOTFS_DIR/usr/lib/libstdc++.so*

. $RULES_DIR/create_ps3kboot.sh
