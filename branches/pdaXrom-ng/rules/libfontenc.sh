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

LIBFONTENC=libfontenc-1.0.4.tar.bz2
LIBFONTENC_MIRROR=ftp://ftp.freedesktop.org/pub/xorg/individual/lib
LIBFONTENC_DIR=$BUILD_DIR/libfontenc-1.0.4
LIBFONTENC_ENV=

build_libfontenc() {
    test -e "$STATE_DIR/libfontenc-1.0.4" && return
    banner "Build $LIBFONTENC"
    download $LIBFONTENC_MIRROR $LIBFONTENC
    extract $LIBFONTENC
    apply_patches $LIBFONTENC_DIR $LIBFONTENC
    pushd $TOP_DIR
    cd $LIBFONTENC_DIR
    (
    eval \
	$CROSS_CONF_ENV \
	$LIBFONTENC_ENV \
	./configure --host=$TARGET_ARCH \
	    --prefix=/usr \
	    --sysconfdir=/etc || error
    )
    make $MAKEARGS || error

    install_sysroot_files || error
    
    $INSTALL -D -m 644 src/.libs/libfontenc.so.1.0.0 $ROOTFS_DIR/usr/lib/libfontenc.so.1.0.0 || error
    ln -sf libfontenc.so.1.0.0 $ROOTFS_DIR/usr/lib/libfontenc.so.1
    ln -sf libfontenc.so.1.0.0 $ROOTFS_DIR/usr/lib/libfontenc.so
    $STRIP $ROOTFS_DIR/usr/lib/libfontenc.so.1.0.0

    popd
    touch "$STATE_DIR/libfontenc-1.0.4"
}

build_libfontenc
