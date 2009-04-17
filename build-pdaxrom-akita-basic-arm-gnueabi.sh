#!/bin/bash

TARGET_ARCH="armel-linux-gnueabi"
TOOLCHAIN_PREFIX="/opt/${TARGET_ARCH}/toolchain"
TOOLCHAIN_SYSROOT="/opt/${TARGET_ARCH}/sysroot"

KERNEL_VERSION="2.6.29.1"
KERNEL_CONFIG=akita-kernel-2.6.29.1

. ./sets/packages-basic.inc

. ./sets/packages-host-squashfs.inc
. $RULES_DIR/create_squashfs.sh
