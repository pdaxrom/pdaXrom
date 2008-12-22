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

XF86_INPUT_KEYBOARD=xf86-input-keyboard-1.3.1.tar.bz2
XF86_INPUT_KEYBOARD_MIRROR=ftp://ftp.freedesktop.org/pub/xorg/individual/driver
XF86_INPUT_KEYBOARD_DIR=$BUILD_DIR/xf86-input-keyboard-1.3.1
XF86_INPUT_KEYBOARD_ENV=

build_xf86_input_keyboard() {
    test -e "$STATE_DIR/xf86_input_keyboard-1.3.1" && return
    banner "Build $XF86_INPUT_KEYBOARD"
    download $XF86_INPUT_KEYBOARD_MIRROR $XF86_INPUT_KEYBOARD
    extract $XF86_INPUT_KEYBOARD
    apply_patches $XF86_INPUT_KEYBOARD_DIR $XF86_INPUT_KEYBOARD
    pushd $TOP_DIR
    cd $XF86_INPUT_KEYBOARD_DIR
    (
    eval \
	$CROSS_CONF_ENV \
	$XF86_INPUT_KEYBOARD_ENV \
	./configure --build=$BUILD_ARCH --host=$TARGET_ARCH \
	    --prefix=/usr \
	    --sysconfdir=/etc \
	    || error
    )
    make $MAKEARGS || error

    $INSTALL -D -m 644 src/.libs/kbd_drv.so $ROOTFS_DIR/usr/lib/xorg/modules/input/kbd_drv.so || error
    $STRIP $ROOTFS_DIR/usr/lib/xorg/modules/input/kbd_drv.so

    popd
    touch "$STATE_DIR/xf86_input_keyboard-1.3.1"
}

build_xf86_input_keyboard
