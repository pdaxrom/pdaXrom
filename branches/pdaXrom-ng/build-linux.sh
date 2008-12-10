#!/bin/bash

TARGET_ARCH="i686-linux"
TOOLCHAIN_PREFIX="/opt/${TARGET_ARCH}/toolchain"
TOOLCHAIN_SYSROOT="/opt/${TARGET_ARCH}/sysroot"
CROSS=i686-linux-
GLIBC_DIR="${TOOLCHAIN_SYSROOT}/lib"

KERNEL_CONFIG=i686_kernel_config

MAKEARGS=-j4

. ./packages.inc

. $RULES_DIR/create_initramfs.sh
