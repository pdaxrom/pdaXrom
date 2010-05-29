#!/bin/bash

if [ "x$TARGET_ARCH" = "x" ]; then
TARGET_ARCH="armel-linux-gnueabi"
fi

TOOLCHAIN_PREFIX="/opt/${TARGET_ARCH}/toolchain"
TOOLCHAIN_SYSROOT="/opt/${TARGET_ARCH}/sysroot"

TARGET_VENDOR_PATCH="zaurus"

KERNEL_VERSION="2.6.34"
KERNEL_CONFIG=akita_kernel_2.6.34_kexecboot

. ./rules/core.sh

. $RULES_DIR/host_pkgconfig.sh
. $RULES_DIR/host_findutils.sh
. $RULES_DIR/host_genext2fs.sh
. $RULES_DIR/host_makebootfat.sh
#. $RULES_DIR/host_module-init-tools.sh
#. $RULES_DIR/host_u-boot-mkimage.sh

. $RULES_DIR/create_root.sh

. $RULES_DIR/linux_kernel.sh

#. $RULES_DIR/busybox.sh
#. $RULES_DIR/host_ncurses.sh
#. $RULES_DIR/ncurses.sh
#. $RULES_DIR/module-init-tools.sh
#. $RULES_DIR/udev.sh
#. $RULES_DIR/install_libc.sh
#. $RULES_DIR/zlib.sh
#. $RULES_DIR/figlet.sh

. $RULES_DIR/kexecboot.sh
#. $RULES_DIR/kbd.sh
#. $BSP_RULES_DIR/survive.sh
#. $RULES_DIR/mtd-utils.sh
#. $BSP_RULES_DIR/spitz_custom.sh
#. $BSP_RULES_DIR/create_emer_initrd.sh
