#!/bin/sh

#export BINUTILS_VERSION=2.19.1
export GCC_VERSION=4.4.3
#export KERNEL_VERSION=2.6.30
#export KERNEL_CONFIG=i686-kernel-2.6.30

export DEFAULT_CPU="armv5te"
export CROSS_OPT_ARCH="-march=armv5te"
#export CROSS_OPT_MABI="-mabi=${DEFAULT_MABI}"

TARGET_ARCH="armel-linux-gnueabi"
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
