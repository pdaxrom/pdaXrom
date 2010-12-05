#!/bin/sh

export BINUTILS_VERSION=2.20.51.0.9
export GCC_VERSION=4.4.4
export KERNEL_VERSION=2.6.29

export DEFAULT_CPU="armv6"
export DEFAULT_FPU="vfp"
export CROSS_OPT_ARCH="-march=armv6 -mtune=arm1136j-s"

TARGET_ARCH="armle-spica-linux-gnueabi"
TOOLCHAIN_SYSROOT="/opt/${TARGET_ARCH}/sysroot"

test -e /opt/${TARGET_ARCH} && mkdir -p /opt/${TARGET_ARCH}

if [ "x$1" = "xclean" ]; then
   . ./build-crosstools.sh clean
else
   . ./build-crosstools.sh $TARGET_ARCH
fi
