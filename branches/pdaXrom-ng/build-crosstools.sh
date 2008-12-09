#!/bin/bash

TARGET_ARCH="i686-linux"
TOOLCHAIN_PREFIX="/opt/${TARGET_ARCH}/toolchain"
TOOLCHAIN_SYSROOT="/opt/${TARGET_ARCH}/sysroot"
CROSS=i686-linux
GLIBC_DIR="${TOOLCHAIN_SYSROOT}/lib"

MAKEARGS=-j4

echo "toolchain prefix $TOOLCHAIN_PREFIX"

. ./rules/core.sh

. $RULES_DIR/host_gmp.sh
. $RULES_DIR/host_mpfr.sh
. $RULES_DIR/cross-linux-tools.sh
