#!/bin/sh

export BINUTILS_VERSION=2.20.51.0.9
export GCC_VERSION=4.4.4
export KERNEL_VERSION=2.6.30

#export DEFAULT_CPU="i686"
#export CROSS_OPT_ARCH="-march=loongson2f"
#export CROSS_OPT_MABI="-mabi=${DEFAULT_MABI}"

TARGET_ARCH="x86_64-linux"
TOOLCHAIN_SYSROOT="/opt/${TARGET_ARCH}/sysroot"

test -e /opt/${TARGET_ARCH} && mkdir -p /opt/${TARGET_ARCH}

mkdir -p $TOOLCHAIN_SYSROOT/usr
ln -sf lib64 $TOOLCHAIN_SYSROOT/lib
ln -sf lib64 $TOOLCHAIN_SYSROOT/usr/lib

if [ "x$1" = "xclean" ]; then
   . ./build-crosstools.sh clean
else
   . ./build-crosstools.sh $TARGET_ARCH
fi
