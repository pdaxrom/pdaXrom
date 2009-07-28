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

XF86_INPUT_JOYSTICK_VERSION=1.4.1
XF86_INPUT_JOYSTICK=xf86-input-joystick-${XF86_INPUT_JOYSTICK_VERSION}.tar.bz2
XF86_INPUT_JOYSTICK_MIRROR=ftp://ftp.freedesktop.org/pub/xorg/individual/driver
XF86_INPUT_JOYSTICK_DIR=$BUILD_DIR/xf86-input-joystick-${XF86_INPUT_JOYSTICK_VERSION}
XF86_INPUT_JOYSTICK_ENV=

build_xf86_input_joystick() {
    test -e "$STATE_DIR/xf86_input_joystick-${XF86_INPUT_JOYSTICK_VERSION}" && return
    banner "Build $XF86_INPUT_JOYSTICK"
    download $XF86_INPUT_JOYSTICK_MIRROR $XF86_INPUT_JOYSTICK
    extract $XF86_INPUT_JOYSTICK
    apply_patches $XF86_INPUT_JOYSTICK_DIR $XF86_INPUT_JOYSTICK
    pushd $TOP_DIR
    cd $XF86_INPUT_JOYSTICK_DIR
    (
    eval \
	$CROSS_CONF_ENV \
	$XF86_INPUT_JOYSTICK_ENV \
	./configure --build=$BUILD_ARCH --host=$TARGET_ARCH \
	    --prefix=/usr \
	    --sysconfdir=/etc \
	    || error
    )
    make $MAKEARGS || error

    $INSTALL -D -m 644 src/.libs/joystick_drv.so $ROOTFS_DIR/usr/lib/xorg/modules/input/joystick_drv.so || error
    $STRIP $ROOTFS_DIR/usr/lib/xorg/modules/input/joystick_drv.so

    popd
    touch "$STATE_DIR/xf86_input_joystick-${XF86_INPUT_JOYSTICK_VERSION}"
}

build_xf86_input_joystick
