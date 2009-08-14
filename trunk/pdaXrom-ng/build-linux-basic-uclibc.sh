#!/bin/bash

TARGET_ARCH="i686-linux-uclibc"
TOOLCHAIN_PREFIX="/opt/${TARGET_ARCH}/toolchain"
TOOLCHAIN_SYSROOT="/opt/${TARGET_ARCH}/sysroot"

KERNEL_VERSION="2.6.30"
KERNEL_CONFIG=i686-kernel-2.6.30
SQUASHFS_LZMA=no

. ./sets/packages-basic.inc

. $RULES_DIR/tweak-i686.sh

. ./sets/packages-host-squashfs4.inc
. $RULES_DIR/create_squashfs.sh
. $RULES_DIR/host_syslinux.sh
. $RULES_DIR/create_x86cd.sh
