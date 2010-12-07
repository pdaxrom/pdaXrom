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

LIBXDMCP_VERSION=1.1.0
LIBXDMCP=libXdmcp-${LIBXDMCP_VERSION}.tar.bz2
LIBXDMCP_MIRROR=ftp://ftp.freedesktop.org/pub/xorg/individual/lib
LIBXDMCP_DIR=$BUILD_DIR/libXdmcp-${LIBXDMCP_VERSION}
LIBXDMCP_ENV=

build_libXdmcp() {
    test -e "$STATE_DIR/libXdmcp-${LIBXDMCP_VERSION}" && return
    banner "Build $LIBXDMCP"
    download $LIBXDMCP_MIRROR $LIBXDMCP
    extract $LIBXDMCP
    apply_patches $LIBXDMCP_DIR $LIBXDMCP
    pushd $TOP_DIR
    cd $LIBXDMCP_DIR
    (
    eval \
	$CROSS_CONF_ENV \
	$LIBXDMCP_ENV \
	./configure --build=$BUILD_ARCH --host=$TARGET_ARCH \
	    --prefix=/usr \
	    --sysconfdir=/etc || error
    )
    make $MAKEARGS || error

    install_sysroot_files || error

    install_fakeroot_init
    install_fakeroot_finish || error

    popd
    touch "$STATE_DIR/libXdmcp-${LIBXDMCP_VERSION}"
}

build_libXdmcp
