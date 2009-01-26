#!/bin/bash

TARGET_ARCH="powerpc-linux-uclibc"
TOOLCHAIN_PREFIX="/opt/${TARGET_ARCH}/toolchain"
TOOLCHAIN_SYSROOT="/opt/${TARGET_ARCH}/sysroot"

KERNEL_CONFIG=ps3_kernel_config

. ./sets/packages-basic.inc

. $RULES_DIR/ps3-utils.sh
. $RULES_DIR/tweak-ps3.sh
. $RULES_DIR/create_initramfs.sh
. $RULES_DIR/create_ps3cd.sh
