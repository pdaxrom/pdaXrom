#!/bin/bash

TARGET_ARCH="powerpc-linux-uclibc"
TOOLCHAIN_PREFIX="/opt/${TARGET_ARCH}/toolchain"
TOOLCHAIN_SYSROOT="/opt/${TARGET_ARCH}/sysroot"

KERNEL_CONFIG=ps3_kboot

. ./rules/core.sh

. $RULES_DIR/host_pkgconfig.sh
. $RULES_DIR/create_root.sh
. $RULES_DIR/linux_kernel.sh
. $RULES_DIR/busybox.sh
. $RULES_DIR/udev.sh
#. $RULES_DIR/wireless_tools.sh
. $RULES_DIR/dhcpcd.sh
. $RULES_DIR/install_libc.sh
#. $RULES_DIR/zlib.sh
#. $RULES_DIR/dropbear.sh
. $RULES_DIR/figlet.sh
. $RULES_DIR/ps3-utils.sh
. $RULES_DIR/kexec-tools.sh
. $RULES_DIR/create_ps3kboot.sh
