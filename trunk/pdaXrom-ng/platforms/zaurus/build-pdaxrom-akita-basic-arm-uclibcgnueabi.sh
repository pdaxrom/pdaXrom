#!/bin/bash

TARGET_ARCH="armel-linux-uclibcgnueabi"
TOOLCHAIN_PREFIX="/opt/${TARGET_ARCH}/toolchain"
TOOLCHAIN_SYSROOT="/opt/${TARGET_ARCH}/sysroot"

KERNEL_VERSION="2.6.29.1"
KERNEL_CONFIG=akita_kernel_2.6.29.1

. $SETS_DIR/packages-basic.inc

. $SETS_DIR/packages-host-squashfs.inc
. $RULES_DIR/create_squashfs.sh
