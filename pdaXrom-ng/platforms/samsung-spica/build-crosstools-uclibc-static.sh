#!/bin/sh

#export BINUTILS_VERSION=2.19.1
#export GCC_VERSION=4.4.1
export LIBGCC_STATIC="yes"

export KERNEL_VERSION=2.6.29

#export KERNEL_CONFIG=i686-kernel-2.6.30
export UCLIBC_CONFIG=armel-static

export DEFAULT_CPU="armv6"
export DEFAULT_FPU="vfp"
export CROSS_OPT_ARCH="-march=armv6 -mtune=arm1136j-s"
#export CROSS_OPT_ARCH="-march=armv6k -mtune=arm1176jzf-s"

#export TARGET_VENDOR_PATCH=samsung-spica

TARGET_ARCH="armle-spica-linux-uclibcgnueabi"
TOOLCHAIN_SYSROOT="/opt/${TARGET_ARCH}/sysroot"

test -e /opt/${TARGET_ARCH} && mkdir -p /opt/${TARGET_ARCH}

if [ "x$1" = "xclean" ]; then
   . ./build-crosstools.sh clean
else
   . ./build-crosstools.sh $TARGET_ARCH
fi
