#!/bin/bash

ISOIMAGE_NAME=atv-pdaXrom-linux
FATIMAGE_NAME=${ISOIMAGE_NAME}

TARGET_ARCH="i686-linux"
TOOLCHAIN_PREFIX="/opt/${TARGET_ARCH}/toolchain"
TOOLCHAIN_SYSROOT="/opt/${TARGET_ARCH}/sysroot"

KERNEL_VERSION="2.6.32"
KERNEL_CONFIG=i686-kernel-2.6.32
TARGET_KERNEL_IMAGE=bzImage

TARGET_GCC_VERSION=4.4.2
TARGET_BINUTILS_VERSION=2.20.51.0.3

USE_SPLASH="yes"
USE_INITRAMFS="yes"
USE_AUFS2="yes"
USE_WEBBROWSER="midori"
USE_LOGINMANAGER="yes"
USE_WINDOWMANAGER="pekwm"

. $SETS_DIR/packages-basic.inc

. $SETS_DIR/packages-acpi.inc

. $SETS_DIR/packages-mmlibs.inc
. $SETS_DIR/packages-libs.inc

. $RULES_DIR/wpa_supplicant.sh

. $SETS_DIR/packages-xorg-xlib.inc
. $SETS_DIR/packages-x-gtk2.inc

. $SETS_DIR/packages-hal.inc

. $SETS_DIR/packages-xorg-xserver.inc
. $SETS_DIR/packages-xorg-drivers.inc
. $SETS_DIR/packages-xorg-apps.inc
. $SETS_DIR/packages-xorg-fonts.inc

. $SETS_DIR/packages-xorg-msttcorefonts.inc

#. $SETS_DIR/packages-emulators.inc

. $SETS_DIR/packages-x-apps.inc

. $RULES_DIR/NVIDIA-Linux-x86.sh

. $SETS_DIR/packages-x-lxde.inc

. $SETS_DIR/packages-x-office.inc

. $SETS_DIR/packages-x-voip.inc

. $SETS_DIR/packages-bluetooth.inc

. $SETS_DIR/packages-x-vkeyboard.inc

. $SETS_DIR/packages-x-rdp.inc

. $SETS_DIR/packages-gparted.inc

. $SETS_DIR/packages-mc.inc
. $SETS_DIR/packages-devel.inc
. $RULES_DIR/geany.sh

. $RULES_DIR/install_locale.sh

. $RULES_DIR/tweak-i686.sh

if [ "$USE_INITRAMFS" = "yes" ]; then
    INITRAMFS_MODULES=`cat $ROOTFS_DIR/lib/modules/*/modules.dep | grep '/scsi/\|/pata/\|/block/' | sed 's/\://' | cut -f1 -d' ' | while read f; do echo ${f/*\/}; done | sed 's/\.ko//' | sort | uniq`
    INITRAMFS_MODULES="$INITRAMFS_MODULES usb-storage ohci-hcd ehci-hcd sg vfat isofs udf nls_cp437 nls_utf8 nls_iso8859-1"
    echo ">>>$INITRAMFS_MODULES"
    . $RULES_DIR/create_initramfs.sh
fi

. $SETS_DIR/packages-host-squashfs.inc
. $RULES_DIR/create_squashfs.sh
. $RULES_DIR/host_syslinux.sh
. $RULES_DIR/create_x86cd.sh
. $RULES_DIR/create_bootfat.sh
