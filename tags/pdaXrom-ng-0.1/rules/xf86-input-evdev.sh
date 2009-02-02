#
# packet template
#
# Copyright (C) 2008 by Alexander Chukov <sash@pdaXrom.org>
#          
# See CREDITS for details about who has contributed to this project.
#
# For further information about the pdaXrom project and license conditions
# see the README file.
#

XF86_INPUT_EVDEV=xf86-input-evdev-2.1.0.tar.bz2
XF86_INPUT_EVDEV_MIRROR=ftp://ftp.freedesktop.org/pub/xorg/individual/driver
XF86_INPUT_EVDEV_DIR=$BUILD_DIR/xf86-input-evdev-2.1.0
XF86_INPUT_EVDEV_ENV=

build_xf86_input_evdev() {
    test -e "$STATE_DIR/xf86_input_evdev-2.1.0" && return
    banner "Build $XF86_INPUT_EVDEV"
    download $XF86_INPUT_EVDEV_MIRROR $XF86_INPUT_EVDEV
    extract $XF86_INPUT_EVDEV
    apply_patches $XF86_INPUT_EVDEV_DIR $XF86_INPUT_EVDEV
    pushd $TOP_DIR
    cd $XF86_INPUT_EVDEV_DIR
    (
    eval \
	$CROSS_CONF_ENV \
	$XF86_INPUT_EVDEV_ENV \
	./configure --build=$BUILD_ARCH --host=$TARGET_ARCH \
	    --prefix=/usr \
	    --sysconfdir=/etc \
	    || error
    )
    make $MAKEARGS || error

    $INSTALL -D -m 644 src/.libs/evdev_drv.so $ROOTFS_DIR/usr/lib/xorg/modules/input/evdev_drv.so || error
    $STRIP $ROOTFS_DIR/usr/lib/xorg/modules/input/evdev_drv.so

    popd
    touch "$STATE_DIR/xf86_input_evdev-2.1.0"
}

build_xf86_input_evdev
