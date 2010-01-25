#!/bin/sh

#export BINUTILS_VERSION=2.19.1
export GCC_VERSION=4.3.2
export KERNEL_VERSION=2.6.24.3
export GLIBC_ENABLE_KERNEL=2.6.24

export TARGET_VENDOR_PATCH=jz

export DEFAULT_CPU="mips3"
#export DEFAULT_FPU=
#export DEFAULT_MABI="n32"

#export CROSS_OPT_ARCH="-march=loongson2f"
#export CROSS_OPT_MABI="-mabi=${DEFAULT_MABI}"

TARGET_ARCH="mipsel-jz-linux"
TOOLCHAIN_SYSROOT="/opt/${TARGET_ARCH}/sysroot"

test -e /opt/${TARGET_ARCH} && mkdir -p /opt/${TARGET_ARCH}

if [ "x$1" = "xclean" ]; then
   . ./build-crosstools.sh clean
else
   . ./build-crosstools.sh $TARGET_ARCH
fi
