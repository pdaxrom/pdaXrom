#!/bin/sh

#export BINUTILS_VERSION=2.19.1
#export GCC_VERSION=4.4.1
export KERNEL_VERSION=2.6.27

#export KERNEL_CONFIG=i686-kernel-2.6.30

export DEFAULT_CPU="armv6k"
export DEFAULT_FPU="vfp"
export CROSS_OPT_ARCH="-march=armv6k -mtune=arm1136j-s"
#export CROSS_OPT_ARCH="-march=armv6 -mtune=arm1176jzfs"

#export TARGET_VENDOR_PATCH=samsung-spica

TARGET_ARCH="armle-spica-linux-uclibcgnueabi"
TOOLCHAIN_SYSROOT="/opt/${TARGET_ARCH}/sysroot"

test -e /opt/${TARGET_ARCH} && mkdir -p /opt/${TARGET_ARCH}

if [ "x$1" = "xclean" ]; then
   . ./build-crosstools.sh clean
else
   . ./build-crosstools.sh $TARGET_ARCH
fi
