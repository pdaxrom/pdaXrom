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

XF86_INPUT_VOID=xf86-input-void-1.1.1.tar.bz2
XF86_INPUT_VOID_MIRROR=ftp://ftp.freedesktop.org/pub/xorg/individual/driver
XF86_INPUT_VOID_DIR=$BUILD_DIR/xf86-input-void-1.1.1
XF86_INPUT_VOID_ENV=

build_xf86_input_void() {
    test -e "$STATE_DIR/xf86_input_void-1.1.1" && return
    banner "Build $XF86_INPUT_VOID"
    download $XF86_INPUT_VOID_MIRROR $XF86_INPUT_VOID
    extract $XF86_INPUT_VOID
    apply_patches $XF86_INPUT_VOID_DIR $XF86_INPUT_VOID
    pushd $TOP_DIR
    cd $XF86_INPUT_VOID_DIR
    (
    eval \
	$CROSS_CONF_ENV \
	$XF86_INPUT_VOID_ENV \
	./configure --host=$TARGET_ARCH \
	    --prefix=/usr \
	    --sysconfdir=/etc \
	    || error
    )
    make $MAKEARGS || error

    $INSTALL -D -m 644 src/.libs/void_drv.so $ROOTFS_DIR/usr/lib/xorg/modules/input/void_drv.so || error
    $STRIP $ROOTFS_DIR/usr/lib/xorg/modules/input/void_drv.so

    popd
    touch "$STATE_DIR/xf86_input_void-1.1.1"
}

build_xf86_input_void
