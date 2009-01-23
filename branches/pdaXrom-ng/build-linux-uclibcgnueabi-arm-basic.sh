#!/bin/bash

TARGET_ARCH="armel-linux-uclibcgnueabi"
TOOLCHAIN_PREFIX="/opt/${TARGET_ARCH}/toolchain"
TOOLCHAIN_SYSROOT="/opt/${TARGET_ARCH}/sysroot"

KERNEL_VERSION="2.6.28"
KERNEL_CONFIG=versatile-kernel-2.6.28

. ./packages-basic.inc

. $RULES_DIR/create_initramfs.sh
