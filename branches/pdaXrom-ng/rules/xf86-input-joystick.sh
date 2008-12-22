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

XF86_INPUT_JOYSTICK=xf86-input-joystick-1.3.3.tar.bz2
XF86_INPUT_JOYSTICK_MIRROR=ftp://ftp.freedesktop.org/pub/xorg/individual/driver
XF86_INPUT_JOYSTICK_DIR=$BUILD_DIR/xf86-input-joystick-1.3.3
XF86_INPUT_JOYSTICK_ENV=

build_xf86_input_joystick() {
    test -e "$STATE_DIR/xf86_input_joystick-1.3.3" && return
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
    touch "$STATE_DIR/xf86_input_joystick-1.3.3"
}

build_xf86_input_joystick
