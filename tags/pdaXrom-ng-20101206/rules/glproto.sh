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

GLPROTO_VERSION=1.4.9
GLPROTO=glproto-${GLPROTO_VERSION}.tar.bz2
GLPROTO_MIRROR=ftp://ftp.freedesktop.org/pub/xorg/individual/proto
GLPROTO_DIR=$BUILD_DIR/glproto-${GLPROTO_VERSION}
GLPROTO_ENV=

build_glproto() {
    test -e "$STATE_DIR/glproto-${GLPROTO_VERSION}" && return
    banner "Build $GLPROTO"
    download $GLPROTO_MIRROR $GLPROTO
    extract $GLPROTO
    apply_patches $GLPROTO_DIR $GLPROTO
    pushd $TOP_DIR
    cd $GLPROTO_DIR
    (
    eval \
	$CROSS_CONF_ENV \
	$GLPROTO_ENV \
	./configure --build=$BUILD_ARCH --host=$TARGET_ARCH \
	    --prefix=/usr \
	    --sysconfdir=/etc \
	    || error
    )
    make $MAKEARGS || error

    install_sysroot_files || error

    popd
    touch "$STATE_DIR/glproto-${GLPROTO_VERSION}"
}

build_glproto
