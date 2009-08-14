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

LIBPNG=libpng-1.2.33.tar.bz2
LIBPNG_MIRROR=http://downloads.sourceforge.net/libpng
LIBPNG_DIR=$BUILD_DIR/libpng-1.2.33
LIBPNG_ENV=

build_libpng() {
    test -e "$STATE_DIR/libpng-1.2.33" && return
    banner "Build $LIBPNG"
    download $LIBPNG_MIRROR $LIBPNG
    extract $LIBPNG
    apply_patches $LIBPNG_DIR $LIBPNG
    pushd $TOP_DIR
    cd $LIBPNG_DIR
    (
    eval \
	$CROSS_CONF_ENV \
	$LIBPNG_ENV \
	./configure --build=$BUILD_ARCH --host=$TARGET_ARCH \
	    --prefix=/usr \
	    --sysconfdir=/etc \
	    --disable-static \
	    || error
    )
    make $MAKEARGS || error

    $INSTALL -m 644 .libs/libpng12.so.0.33.0 $TARGET_LIB/
    ln -sf libpng12.so.0.33.0 $TARGET_LIB/libpng12.so.0
    ln -sf libpng12.so.0.33.0 $TARGET_LIB/libpng12.so
    ln -sf libpng12.so.0.33.0 $TARGET_LIB/libpng.so
    $INSTALL -D -m 644 pngconf.h $TARGET_INC/libpng12/pngconf.h
    $INSTALL -D -m 644 png.h $TARGET_INC/libpng12/png.h
    ln -sf libpng12 $TARGET_INC/libpng
    ln -sf libpng12/pngconf.h $TARGET_INC/
    ln -sf libpng12/png.h $TARGET_INC/
    $INSTALL -D -m 644 libpng12.pc $TARGET_LIB/pkgconfig/libpng12.pc
    ln -s libpng12.pc $TARGET_LIB/pkgconfig/libpng.pc
    sed -i -e "/^prefix=/s:\(prefix=\)\(/usr\):\1${TARGET_BIN_DIR}\2:g" $TARGET_LIB/pkgconfig/libpng12.pc

    $INSTALL -m 644 .libs/libpng12.so.0.33.0 $ROOTFS_DIR/usr/lib/
    ln -sf libpng12.so.0.33.0 $ROOTFS_DIR/usr/lib/libpng12.so.0
    ln -sf libpng12.so.0.33.0 $ROOTFS_DIR/usr/lib/libpng12.so
    ln -sf libpng12.so.0.33.0 $ROOTFS_DIR/usr/lib/libpng.so
    $STRIP $ROOTFS_DIR/usr/lib/libpng12.so.0.33.0

    popd
    touch "$STATE_DIR/libpng-1.2.33"
}

build_libpng
