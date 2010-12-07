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

XF86_INPUT_MOUSE_VERSION=1.6.0
XF86_INPUT_MOUSE=xf86-input-mouse-${XF86_INPUT_MOUSE_VERSION}.tar.bz2
XF86_INPUT_MOUSE_MIRROR=ftp://ftp.freedesktop.org/pub/xorg/individual/driver
XF86_INPUT_MOUSE_DIR=$BUILD_DIR/xf86-input-mouse-${XF86_INPUT_MOUSE_VERSION}
XF86_INPUT_MOUSE_ENV=

build_xf86_input_mouse() {
    test -e "$STATE_DIR/xf86_input_mouse-${XF86_INPUT_MOUSE_VERSION}" && return
    banner "Build $XF86_INPUT_MOUSE"
    download $XF86_INPUT_MOUSE_MIRROR $XF86_INPUT_MOUSE
    extract $XF86_INPUT_MOUSE
    apply_patches $XF86_INPUT_MOUSE_DIR $XF86_INPUT_MOUSE
    pushd $TOP_DIR
    cd $XF86_INPUT_MOUSE_DIR
    (
    eval \
	$CROSS_CONF_ENV \
	$XF86_INPUT_MOUSE_ENV \
	./configure --build=$BUILD_ARCH --host=$TARGET_ARCH \
	    --prefix=/usr \
	    --sysconfdir=/etc \
	    || error
    )
    make $MAKEARGS || error

    $INSTALL -D -m 644 src/.libs/mouse_drv.so $ROOTFS_DIR/usr/lib/xorg/modules/input/mouse_drv.so || error
    $STRIP $ROOTFS_DIR/usr/lib/xorg/modules/input/mouse_drv.so

    popd
    touch "$STATE_DIR/xf86_input_mouse-${XF86_INPUT_MOUSE_VERSION}"
}

build_xf86_input_mouse
