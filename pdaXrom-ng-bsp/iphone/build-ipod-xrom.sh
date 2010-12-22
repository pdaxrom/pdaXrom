#!/bin/bash

TARGET_ARCH="armle-spica-linux-gnueabi"
TOOLCHAIN_PREFIX="/opt/${TARGET_ARCH}/toolchain"
TOOLCHAIN_SYSROOT="/opt/${TARGET_ARCH}/sysroot"

export KERNEL_VERSION=2.6.32
export KERNEL_CONFIG=ipod1g-2.6.32

TARGET_KERNEL_IMAGE=zImage
TARGET_VENDOR_PATCH=ipod1g

USE_AUFS2="yes"

INSTALL_PEKWM_THEMES="nimbus"

#INITRAMFS_MODULES="psfreedom"
#INITRAMFS_MODULES_SEQUENCE="psfreedom"

. $SETS_DIR/packages-basic.inc
. $BSP_RULES_DIR/PSFreedom.sh
. $SETS_DIR/packages-mmlibs.inc
. $SETS_DIR/packages-libs.inc
. $RULES_DIR/wpa_supplicant.sh

. $SETS_DIR/packages-xorg-xlib.inc
#. $SETS_DIR/packages-x-gtk2.inc

#. $SETS_DIR/packages-hal.inc
#. $SETS_DIR/packages-devicekit.inc

. $SETS_DIR/packages-xorg-xserver-kdrive.inc

. $RULES_DIR/xf86-input-evdev.sh
. $RULES_DIR/xf86-input-joystick.sh
. $RULES_DIR/xf86-input-keyboard.sh
. $RULES_DIR/xf86-input-mouse.sh
. $RULES_DIR/xf86-video-fbdev.sh
. $RULES_DIR/xf86-video-v4l.sh

. $SETS_DIR/packages-xorg-apps.inc
. $SETS_DIR/packages-xorg-fonts.inc

. $SETS_DIR/packages-xorg-msttcorefonts.inc

#. $SETS_DIR/packages-x-apps.inc

. $RULES_DIR/htop.sh
. $RULES_DIR/mrxvt05utf8.sh
. $SETS_DIR/packages-x-vkeyboard.inc

#. $SETS_DIR/packages-x-office.inc

#. $SETS_DIR/packages-x-voip.inc

#. $SETS_DIR/packages-gparted.inc

. $RULES_DIR/imlib2.sh
#. $RULES_DIR/bmpanel.sh
. $RULES_DIR/cairo.sh
. $RULES_DIR/pango.sh
. $RULES_DIR/tint2.sh
#. $RULES_DIR/sn-monitor.sh
. $RULES_DIR/pekwm.sh
. $RULES_DIR/pekwm-themes.sh
#. $RULES_DIR/minidesk-utils.sh
. $RULES_DIR/xdotool.sh
#. $RULES_DIR/lxde-tweaks.sh

$INSTALL -D -m 755 ${GENERICFS_DIR}/minidesk/minidesk-session ${ROOTFS_DIR}/usr/bin/minidesk-session
echo "exec /usr/bin/minidesk-session" > ${ROOTFS_DIR}/etc/X11/Xsession.d/90_minidesk

#. $SETS_DIR/packages-x-lxde.inc

#. $SETS_DIR/packages-mc.inc
#. $SETS_DIR/packages-devel.inc
#. $RULES_DIR/geany.sh

. $RULES_DIR/install_locale.sh

$INSTALL -m 644 ${BSP_GENERICFS_DIR}/modules ${ROOTFS_DIR}/etc/
$INSTALL -m 644 ${BSP_GENERICFS_DIR}/inittab ${ROOTFS_DIR}/etc/
$INSTALL -m 755 ${BSP_GENERICFS_DIR}/rc.local ${ROOTFS_DIR}/etc/

. $BSP_RULES_DIR/tweak-ipod.sh

. $SETS_DIR/packages-host-squashfs.inc
. $RULES_DIR/create_squashfs.sh
. $BSP_RULES_DIR/create_initramfs.sh
