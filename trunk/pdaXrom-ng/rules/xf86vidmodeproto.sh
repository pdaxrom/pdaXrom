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

XF86VIDMODEPROTO_VERSION=2.3
XF86VIDMODEPROTO=xf86vidmodeproto-${XF86VIDMODEPROTO_VERSION}.tar.bz2
XF86VIDMODEPROTO_MIRROR=ftp://ftp.freedesktop.org/pub/xorg/individual/proto
XF86VIDMODEPROTO_DIR=$BUILD_DIR/xf86vidmodeproto-${XF86VIDMODEPROTO_VERSION}
XF86VIDMODEPROTO_ENV=

build_xf86vidmodeproto() {
    test -e "$STATE_DIR/xf86vidmodeproto-${XF86VIDMODEPROTO_VERSION}" && return
    banner "Build $XF86VIDMODEPROTO"
    download $XF86VIDMODEPROTO_MIRROR $XF86VIDMODEPROTO
    extract $XF86VIDMODEPROTO
    apply_patches $XF86VIDMODEPROTO_DIR $XF86VIDMODEPROTO
    pushd $TOP_DIR
    cd $XF86VIDMODEPROTO_DIR
    (
    eval \
	$CROSS_CONF_ENV \
	$XF86VIDMODEPROTO_ENV \
	./configure --build=$BUILD_ARCH --host=$TARGET_ARCH \
	    --prefix=/usr \
	    --sysconfdir=/etc \
	    || error
    )
    make $MAKEARGS || error

    install_sysroot_files || error

    popd
    touch "$STATE_DIR/xf86vidmodeproto-${XF86VIDMODEPROTO_VERSION}"
}

build_xf86vidmodeproto
