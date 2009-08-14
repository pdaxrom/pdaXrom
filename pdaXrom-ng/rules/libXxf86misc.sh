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

LIBXXF86MISC=libXxf86misc-1.0.1.tar.bz2
LIBXXF86MISC_MIRROR=ftp://ftp.freedesktop.org/pub/xorg/individual/lib
LIBXXF86MISC_DIR=$BUILD_DIR/libXxf86misc-1.0.1
LIBXXF86MISC_ENV=

build_libXxf86misc() {
    test -e "$STATE_DIR/libXxf86misc-1.0.1" && return
    banner "Build $LIBXXF86MISC"
    download $LIBXXF86MISC_MIRROR $LIBXXF86MISC
    extract $LIBXXF86MISC
    apply_patches $LIBXXF86MISC_DIR $LIBXXF86MISC
    pushd $TOP_DIR
    cd $LIBXXF86MISC_DIR
    (
    eval \
	$CROSS_CONF_ENV \
	$LIBXXF86MISC_ENV \
	./configure --build=$BUILD_ARCH --host=$TARGET_ARCH \
	    --prefix=/usr \
	    --sysconfdir=/etc \
	    --disable-malloc0returnsnull \
	    || error
    )
    make $MAKEARGS || error

    install_sysroot_files || error
    
    $INSTALL -D -m 644 src/.libs/libXxf86misc.so.1.1.0 $ROOTFS_DIR/usr/lib/libXxf86misc.so.1.1.0 || error
    ln -sf libXxf86misc.so.1.1.0 $ROOTFS_DIR/usr/lib/libXxf86misc.so.1
    ln -sf libXxf86misc.so.1.1.0 $ROOTFS_DIR/usr/lib/libXxf86misc.so
    $STRIP $ROOTFS_DIR/usr/lib/libXxf86misc.so.1.1.0

    popd
    touch "$STATE_DIR/libXxf86misc-1.0.1"
}

build_libXxf86misc
