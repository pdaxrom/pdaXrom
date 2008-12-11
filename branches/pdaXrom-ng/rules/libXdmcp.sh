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

LIBXDMCP=libXdmcp-1.0.2.tar.bz2
LIBXDMCP_MIRROR=ftp://ftp.freedesktop.org/pub/xorg/individual/lib
LIBXDMCP_DIR=$BUILD_DIR/libXdmcp-1.0.2
LIBXDMCP_ENV=

build_libXdmcp() {
    test -e "$STATE_DIR/libXdmcp-1.0.2" && return
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
	./configure --host=$TARGET_ARCH \
	    --prefix=/usr \
	    --sysconfdir=/etc || error
    )
    make $MAKEARGS || error

    install_sysroot_files || error

    $INSTALL -D -m 644 .libs/libXdmcp.so.6.0.0 $ROOTFS_DIR/usr/lib/libXdmcp.so.6.0.0 || error
    ln -sf libXdmcp.so.6.0.0 $ROOTFS_DIR/usr/lib/libXdmcp.so.6
    ln -sf libXdmcp.so.6.0.0 $ROOTFS_DIR/usr/lib/libXdmcp.so
    $STRIP $ROOTFS_DIR/usr/lib/libXdmcp.so.6.0.0

    popd
    touch "$STATE_DIR/libXdmcp-1.0.2"
}

build_libXdmcp
