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

XF86DGAPROTO=xf86dgaproto-2.0.3.tar.bz2
XF86DGAPROTO_MIRROR=ftp://ftp.freedesktop.org/pub/xorg/X11R7.3/src/proto
XF86DGAPROTO_DIR=$BUILD_DIR/xf86dgaproto-2.0.3
XF86DGAPROTO_ENV=

build_xf86dgaproto() {
    test -e "$STATE_DIR/xf86dgaproto-2.0.3" && return
    banner "Build $XF86DGAPROTO"
    download $XF86DGAPROTO_MIRROR $XF86DGAPROTO
    extract $XF86DGAPROTO
    apply_patches $XF86DGAPROTO_DIR $XF86DGAPROTO
    pushd $TOP_DIR
    cd $XF86DGAPROTO_DIR
    (
    eval \
	$CROSS_CONF_ENV \
	$XF86DGAPROTO_ENV \
	./configure --host=$TARGET_ARCH \
	    --prefix=/usr \
	    --sysconfdir=/etc \
	    || error
    )
    make $MAKEARGS || error

    install_sysroot_files || error

    popd
    touch "$STATE_DIR/xf86dgaproto-2.0.3"
}

build_xf86dgaproto
