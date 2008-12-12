#!/bin/bash

TARGET_ARCH="i686-linux"

case $1 in
    *-linux*)
	TARGET_ARCH=$1
    ;;
esac

TOOLCHAIN_PREFIX="/opt/${TARGET_ARCH}/toolchain"
TOOLCHAIN_SYSROOT="/opt/${TARGET_ARCH}/sysroot"
CROSS=$TARGET_ARCH
GLIBC_DIR="${TOOLCHAIN_SYSROOT}/lib"

MAKEARGS=-j4

echo "toolchain prefix  $TOOLCHAIN_PREFIX"
echo "toolchain sysroot $TOOLCHAIN_SYSROOT"
echo "target arch       $TARGET_ARCH"

. ./rules/core.sh

. $RULES_DIR/host_gmp.sh
. $RULES_DIR/host_mpfr.sh
. $RULES_DIR/cross-linux-tools.sh
