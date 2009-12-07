#!/bin/bash

TARGET_ARCH="i686-linux-uclibc"
TOOLCHAIN_PREFIX="/opt/${TARGET_ARCH}/toolchain"
TOOLCHAIN_SYSROOT="/opt/${TARGET_ARCH}/sysroot"

DARWIN_TOOLCHAINS_PREFIX="/opt/i686-apple-darwin10/toolchain/bin/i686-apple-darwin10-"

KERNEL_VERSION="2.6.32"
KERNEL_CONFIG=kernel-2.6.32

TARGET_KERNEL_IMAGE=bzImage

. $SETS_DIR/packages-basic.inc

. $RULES_DIR/kexec-tools.sh

. $RULES_DIR/tweak-i686.sh

. $BSP_RULES_DIR/host_parted.sh
. $BSP_RULES_DIR/host_diskdev-cmds.sh
. $SETS_DIR/packages-host-squashfs.inc

. $RULES_DIR/create_squashfs.sh
. $BSP_RULES_DIR/atv-bootloader.sh

. $RULES_DIR/host_syslinux.sh
. $RULES_DIR/create_x86cd.sh
