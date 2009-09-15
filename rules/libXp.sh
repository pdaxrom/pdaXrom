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

LIBXP=libXp-1.0.0.tar.bz2
LIBXP_MIRROR=ftp://ftp.freedesktop.org/pub/xorg/individual/lib
LIBXP_DIR=$BUILD_DIR/libXp-1.0.0
LIBXP_ENV=

build_libXp() {
    test -e "$STATE_DIR/libXp-1.0.0" && return
    banner "Build $LIBXP"
    download $LIBXP_MIRROR $LIBXP
    extract $LIBXP
    apply_patches $LIBXP_DIR $LIBXP
    pushd $TOP_DIR
    cd $LIBXP_DIR
    (
    eval \
	$CROSS_CONF_ENV \
	$LIBXP_ENV \
	./configure --build=$BUILD_ARCH --host=$TARGET_ARCH \
	    --prefix=/usr \
	    --sysconfdir=/etc \
	    --disable-malloc0returnsnull \
	    || error
    )
    make $MAKEARGS || error

    install_sysroot_files || error
    
    $INSTALL -D -m 644 src/.libs/libXp.so.6.2.0 $ROOTFS_DIR/usr/lib/libXp.so.6.2.0 || error
    ln -sf libXp.so.6.2.0 $ROOTFS_DIR/usr/lib/libXp.so.6
    ln -sf libXp.so.6.2.0 $ROOTFS_DIR/usr/lib/libXp.so
    $STRIP $ROOTFS_DIR/usr/lib/libXp.so.6.2.0

    popd
    touch "$STATE_DIR/libXp-1.0.0"
}

build_libXp
