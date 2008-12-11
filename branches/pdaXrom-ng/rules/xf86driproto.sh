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

XF86DRIPROTO=xf86driproto-2.0.4.tar.bz2
XF86DRIPROTO_MIRROR=ftp://ftp.freedesktop.org/pub/xorg/individual/proto
XF86DRIPROTO_DIR=$BUILD_DIR/xf86driproto-2.0.4
XF86DRIPROTO_ENV=

build_xf86driproto() {
    test -e "$STATE_DIR/xf86driproto-2.0.3" && return
    banner "Build $XF86DRIPROTO"
    download $XF86DRIPROTO_MIRROR $XF86DRIPROTO
    extract $XF86DRIPROTO
    apply_patches $XF86DRIPROTO_DIR $XF86DRIPROTO
    pushd $TOP_DIR
    cd $XF86DRIPROTO_DIR
    (
    eval \
	$CROSS_CONF_ENV \
	$XF86DRIPROTO_ENV \
	./configure --host=$TARGET_ARCH \
	    --prefix=/usr \
	    --sysconfdir=/etc \
	    || error
    )
    make $MAKEARGS || error

    install_sysroot_files || error

    popd
    touch "$STATE_DIR/xf86driproto-2.0.3"
}

build_xf86driproto
