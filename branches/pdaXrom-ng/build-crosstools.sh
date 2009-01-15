#!/bin/bash

TARGET_ARCH="i686-linux"

case $1 in
*-linux*|*-cygwin*|*-mingw32*)
    TARGET_ARCH=$1
    ;;
*)
    TARGET_ARCH=""
    ;;
esac

TOOLCHAIN_PREFIX="/opt/${TARGET_ARCH}/toolchain"
TOOLCHAIN_SYSROOT="/opt/${TARGET_ARCH}/sysroot"
CROSS=$TARGET_ARCH
GLIBC_DIR="${TOOLCHAIN_SYSROOT}/lib"

CROSS=${TARGET_ARCH}-

echo "toolchain prefix  $TOOLCHAIN_PREFIX"
echo "toolchain sysroot $TOOLCHAIN_SYSROOT"
echo "target arch       $TARGET_ARCH"

. ./rules/core.sh

case $TARGET_ARCH in
*linux*)
    . $RULES_DIR/host_gmp.sh
    . $RULES_DIR/host_mpfr.sh
    case $TARGET_ARCH in
    *uclibc*)
	. $RULES_DIR/cross-linux-uclibc-tools.sh
	;;
    *)
	. $RULES_DIR/cross-linux-tools.sh
	;;
    esac
    ;;
*cygwin*)
    . $RULES_DIR/cross-cygwin-tools.sh
    . $RULES_DIR/mingw32-zlib.sh
    . $RULES_DIR/mingw32-libjpeg.sh
    . $RULES_DIR/mingw32-libpng.sh
    . $RULES_DIR/mingw32-SDL.sh
    . $RULES_DIR/mingw32-qemu.sh
    ;;
*mingw32*)
    #. $RULES_DIR/cross-mingw32-tools.sh
    echo "For create mingw32 binaries, please use cygwin compiler with -mno-cygwin option"
    ;;
*)
    error "unknown target $TARGET_ARCH"
    ;;
esac
