#!/bin/bash

TARGET_ARCH="armle-spica-linux-gnueabi"
TOOLCHAIN_PREFIX="/opt/${TARGET_ARCH}/toolchain"
TOOLCHAIN_SYSROOT="/opt/${TARGET_ARCH}/sysroot"

export KERNEL_VERSION=2.6.27
export KERNEL_CONFIG=spica-pdaXrom-2.6.27

TARGET_KERNEL_IMAGE=zImage
TARGET_VENDOR_PATCH=samsung-spica

INITRAMFS_MODULES="multipdp vibrator s3c_rotator s3c_mfc s3c_g2d_driver s3c_pp s3c_jpeg s3c_g3d s3c_cmm s3c_camera param btgpio"
INITRAMFS_MODULES_SEQUENCE="multipdp vibrator s3c_rotator s3c_mfc s3c_g2d_driver s3c_pp s3c_jpeg s3c_g3d s3c_cmm s3c_camera param btgpio"

FFMPEG_CONFIGURE_OPTS="--enable-armvfp --enable-armv6"

. $SETS_DIR/packages-basic.inc
. $SETS_DIR/packages-acpi.inc
. $SETS_DIR/packages-mmlibs.inc
. $SETS_DIR/packages-libs.inc

. $RULES_DIR/wpa_supplicant.sh

. $SETS_DIR/packages-xorg-xlib.inc
. $SETS_DIR/packages-x-gtk2.inc

. $SETS_DIR/packages-hal.inc

. $SETS_DIR/packages-xorg-xserver.inc

. $RULES_DIR/xf86-input-evdev.sh
. $RULES_DIR/xf86-input-keyboard.sh
. $RULES_DIR/xf86-input-mouse.sh
. $RULES_DIR/xf86-video-fbdev.sh
. $RULES_DIR/xf86-video-v4l.sh

. $SETS_DIR/packages-xorg-apps.inc
. $SETS_DIR/packages-xorg-fonts.inc

. $SETS_DIR/packages-xorg-msttcorefonts.inc

#. $SETS_DIR/packages-emulators.inc

. $SETS_DIR/packages-x-apps.inc

. $SETS_DIR/packages-x-lxde.inc

#. $SETS_DIR/packages-x-office.inc

#. $SETS_DIR/packages-x-voip.inc

#. $SETS_DIR/packages-gparted.inc

#. $SETS_DIR/packages-mc.inc
#. $SETS_DIR/packages-devel.inc
#. $RULES_DIR/geany.sh

#. $RULES_DIR/install_locale.sh

. $BSP_RULES_DIR/build-spica-mods.sh
#. $BSP_RULES_DIR/build-adbd.sh

. $BSP_RULES_DIR/tweak-spica.sh

. $SETS_DIR/packages-host-squashfs.inc
. $RULES_DIR/create_squashfs.sh

. $BSP_RULES_DIR/create_initramfs.sh
