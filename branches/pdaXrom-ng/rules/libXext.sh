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

LIBXEXT=libXext-1.0.4.tar.bz2
LIBXEXT_MIRROR=ftp://ftp.freedesktop.org/pub/xorg/individual/lib
LIBXEXT_DIR=$BUILD_DIR/libXext-1.0.4
LIBXEXT_ENV=

build_libXext() {
    test -e "$STATE_DIR/libXext-1.0.2" && return
    banner "Build $LIBXEXT"
    download $LIBXEXT_MIRROR $LIBXEXT
    extract $LIBXEXT
    apply_patches $LIBXEXT_DIR $LIBXEXT
    pushd $TOP_DIR
    cd $LIBXEXT_DIR
    (
    eval \
	$CROSS_CONF_ENV \
	$LIBXEXT_ENV \
	./configure --host=$TARGET_ARCH \
	    --prefix=/usr \
	    --sysconfdir=/etc \
	    --disable-malloc0returnsnull \
	    || error
    )
    make $MAKEARGS || error

    install_sysroot_files || error
    
    $INSTALL -D -m 644 src/.libs/libXext.so.6.4.0 $ROOTFS_DIR/usr/lib/libXext.so.6.4.0 || error
    ln -sf libXext.so.6.4.0 $ROOTFS_DIR/usr/lib/libXext.so.6
    ln -sf libXext.so.6.4.0 $ROOTFS_DIR/usr/lib/libXext.so
    $STRIP $ROOTFS_DIR/usr/lib/libXext.so.6.4.0

    popd
    touch "$STATE_DIR/libXext-1.0.2"
}

build_libXext
