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

XF86BIGFONTPROTO_VERSION=1.2.0
XF86BIGFONTPROTO=xf86bigfontproto-${XF86BIGFONTPROTO_VERSION}.tar.bz2
XF86BIGFONTPROTO_MIRROR=ftp://ftp.freedesktop.org/pub/xorg/individual/proto
XF86BIGFONTPROTO_DIR=$BUILD_DIR/xf86bigfontproto-${XF86BIGFONTPROTO_VERSION}
XF86BIGFONTPROTO_ENV=

build_xf86bigfontproto() {
    test -e "$STATE_DIR/xf86bigfontproto-${XF86BIGFONTPROTO_VERSION}" && return
    banner "Build $XF86BIGFONTPROTO"
    download $XF86BIGFONTPROTO_MIRROR $XF86BIGFONTPROTO
    extract $XF86BIGFONTPROTO
    apply_patches $XF86BIGFONTPROTO_DIR $XF86BIGFONTPROTO
    pushd $TOP_DIR
    cd $XF86BIGFONTPROTO_DIR
    (
    eval \
	$CROSS_CONF_ENV \
	$XF86BIGFONTPROTO_ENV \
	./configure --build=$BUILD_ARCH --host=$TARGET_ARCH \
	    --prefix=/usr \
	    --sysconfdir=/etc \
	    || error
    )
    make $MAKEARGS || error

    install_sysroot_files || error

    popd
    touch "$STATE_DIR/xf86bigfontproto-${XF86BIGFONTPROTO_VERSION}"
}

build_xf86bigfontproto
