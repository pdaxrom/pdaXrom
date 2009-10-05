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

XF86MISCPROTO_VERSION=0.9.2
XF86MISCPROTO=xf86miscproto-${XF86MISCPROTO_VERSION}.tar.bz2
XF86MISCPROTO_MIRROR=ftp://ftp.freedesktop.org/pub/xorg/individual/proto
XF86MISCPROTO_DIR=$BUILD_DIR/xf86miscproto-${XF86MISCPROTO_VERSION}
XF86MISCPROTO_ENV=

build_xf86miscproto() {
    test -e "$STATE_DIR/xf86miscproto-${XF86MISCPROTO_VERSION}" && return
    banner "Build $XF86MISCPROTO"
    download $XF86MISCPROTO_MIRROR $XF86MISCPROTO
    extract $XF86MISCPROTO
    apply_patches $XF86MISCPROTO_DIR $XF86MISCPROTO
    pushd $TOP_DIR
    cd $XF86MISCPROTO_DIR
    (
    eval \
	$CROSS_CONF_ENV \
	$XF86MISCPROTO_ENV \
	./configure --build=$BUILD_ARCH --host=$TARGET_ARCH \
	    --prefix=/usr \
	    --sysconfdir=/etc \
	    || error
    )
    make $MAKEARGS || error

    install_sysroot_files || error

    popd
    touch "$STATE_DIR/xf86miscproto-${XF86MISCPROTO_VERSION}"
}

build_xf86miscproto
