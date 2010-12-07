#!/bin/bash

TARGET_ARCH="i686-linux-uclibc"
TOOLCHAIN_PREFIX="/opt/${TARGET_ARCH}/toolchain"
TOOLCHAIN_SYSROOT="/opt/${TARGET_ARCH}/sysroot"

KERNEL_VERSION="2.6.36"
KERNEL_CONFIG=i686-kernel-2.6.36

. $SETS_DIR/packages-basic.inc

. $RULES_DIR/tweak-i686.sh

. $SETS_DIR/packages-host-squashfs4.inc
. $RULES_DIR/create_squashfs4.sh
. $RULES_DIR/host_syslinux.sh
. $RULES_DIR/create_x86cd.sh
