#!/bin/sh

#export BINUTILS_VERSION=2.19.1
export GCC_VERSION=4.4.1
export KERNEL_VERSION=2.6.29.2

export KERNEL_CONFIG=yeeloong_2.6.29.2
export TARGET_VENDOR_PATCH=ls2f

#export DEFAULT_CPU=
#export DEFAULT_FPU=
export DEFAULT_MABI="n32"

export CROSS_OPT_ARCH="-march=loongson2f"
export CROSS_OPT_MABI="-mabi=${DEFAULT_MABI}"

TARGET_ARCH="mips64el-linux"
TOOLCHAIN_SYSROOT="/opt/${TARGET_ARCH}/sysroot"

test -e /opt/${TARGET_ARCH} && mkdir -p /opt/${TARGET_ARCH}

mkdir -p $TOOLCHAIN_SYSROOT/usr
ln -sf lib32 $TOOLCHAIN_SYSROOT/lib
ln -sf lib32 $TOOLCHAIN_SYSROOT/usr/lib

if [ "x$1" = "xclean" ]; then
   ./build-crosstools.sh clean
else
   ./build-crosstools.sh $TARGET_ARCH
fi
