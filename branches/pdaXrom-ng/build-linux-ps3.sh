#!/bin/bash

TARGET_ARCH="powerpc-linux"
TOOLCHAIN_PREFIX="/opt/cell/toolchain"
TOOLCHAIN_SYSROOT="/opt/cell/sysroot"
CROSS=ppu-
GLIBC_DIR="${TOOLCHAIN_SYSROOT}/lib"

KERNEL_CONFIG=ps3_kernel_config

MAKEARGS=-j4

. ./packages.inc
