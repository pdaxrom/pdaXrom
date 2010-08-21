#!/bin/sh

export BINUTILS_VERSION=2.20.51.0.11
export GCC_VERSION=4.4.4
#export BINUTILS_VERSION=2.19.1
#export GCC_VERSION=4.4.1

export KERNEL_VERSION="2.6.30"
export TARGET_VENDOR_PATCH=ps3

#export DEFAULT_CPU="cell"
#export CROSS_OPT_ARCH="-mtune=cell"
#export CROSS_OPT_MABI="-mabi=${DEFAULT_MABI}"

export UCLIBC_CONFIG=powerpc-config-wchar-locale

TARGET_ARCH="powerpc-ps3-linux-uclibc"
TOOLCHAIN_SYSROOT="/opt/${TARGET_ARCH}/sysroot"

test -e /opt/${TARGET_ARCH} && mkdir -p /opt/${TARGET_ARCH}

#mkdir -p $TOOLCHAIN_SYSROOT/usr
#ln -sf lib32 $TOOLCHAIN_SYSROOT/lib
#ln -sf lib32 $TOOLCHAIN_SYSROOT/usr/lib

if [ "x$1" = "xclean" ]; then
   . ./build-crosstools.sh clean
else
   . ./build-crosstools.sh $TARGET_ARCH
fi
