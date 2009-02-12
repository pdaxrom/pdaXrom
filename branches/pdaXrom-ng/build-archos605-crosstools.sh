#!/bin/sh

CONF_ARCHOS=1

UCLIBC_CONFIG=archos605-config
KERNEL_VERSION=2.6.28
#KERNEL_CONFIG=archos605_kernel_2.6.10
#TARGET_VENDOR_PATCH=archos


if [ "x$1" = "xclean" ]; then
   . ./build-crosstools.sh clean
else
   . ./build-crosstools.sh armel-linux-uclibc
fi
