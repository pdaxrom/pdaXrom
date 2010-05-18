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

XF86_INPUT_VMMOUSE_VERSION=12.6.4
XF86_INPUT_VMMOUSE=xf86-input-vmmouse-${XF86_INPUT_VMMOUSE_VERSION}.tar.bz2
XF86_INPUT_VMMOUSE_MIRROR=ftp://ftp.freedesktop.org/pub/xorg/individual/driver
XF86_INPUT_VMMOUSE_DIR=$BUILD_DIR/xf86-input-vmmouse-${XF86_INPUT_VMMOUSE_VERSION}
XF86_INPUT_VMMOUSE_ENV=

build_xf86_input_vmmouse() {
    test -e "$STATE_DIR/xf86_input_vmmouse-${XF86_INPUT_VMMOUSE_VERSION}" && return
    banner "Build $XF86_INPUT_VMMOUSE"
    download $XF86_INPUT_VMMOUSE_MIRROR $XF86_INPUT_VMMOUSE
    extract $XF86_INPUT_VMMOUSE
    apply_patches $XF86_INPUT_VMMOUSE_DIR $XF86_INPUT_VMMOUSE
    pushd $TOP_DIR
    cd $XF86_INPUT_VMMOUSE_DIR
    (
    eval \
	$CROSS_CONF_ENV \
	$XF86_INPUT_VMMOUSE_ENV \
	./configure --build=$BUILD_ARCH --host=$TARGET_ARCH \
	    --prefix=/usr \
	    --sysconfdir=/etc \
	    || error
    )
    make $MAKEARGS || error

    $INSTALL -D -m 644 src/.libs/vmmouse_drv.so $ROOTFS_DIR/usr/lib/xorg/modules/input/vmmouse_drv.so || error
    $STRIP $ROOTFS_DIR/usr/lib/xorg/modules/input/vmmouse_drv.so

    popd
    touch "$STATE_DIR/xf86_input_vmmouse-${XF86_INPUT_VMMOUSE_VERSION}"
}

build_xf86_input_vmmouse
