#!/bin/sh

TARGET_ARCH="i686-apple-darwin10"
TOOLCHAIN_SYSROOT="/opt/${TARGET_ARCH}/sysroot"

test -e /opt/${TARGET_ARCH} && mkdir -p /opt/${TARGET_ARCH}

if [ "x$1" = "xclean" ]; then
   ./build-crosstools.sh clean
else
   ./build-crosstools.sh $TARGET_ARCH
fi
