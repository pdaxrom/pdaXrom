#!/bin/sh

export BINUTILS_VERSION=2.20.51.0.9
export GCC_VERSION=4.4.5
export KERNEL_VERSION=2.6.30

export TARGET_VENDOR_PATCH=ls2f

export DEFAULT_CPU="loongson2f"

export CROSS_OPT_ARCH="-march=loongson2f -mtune=loongson2f"
export CROSS_OPT_CFLAGS="-O3"
export CROSS_OPT_CXXFLAGS="-O3"

TARGET_ARCH="mipsel-ls2f-linux"
TOOLCHAIN_SYSROOT="/opt/${TARGET_ARCH}/sysroot"

test -e /opt/${TARGET_ARCH} && mkdir -p /opt/${TARGET_ARCH}

if [ "x$1" = "xclean" ]; then
   . ./build-crosstools.sh clean
else
   . ./build-crosstools.sh $TARGET_ARCH
fi
