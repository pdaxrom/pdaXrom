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

ZLIB=zlib-1.2.3-ptx4.tar.bz2
ZLIB_MIRROR=http://www.pengutronix.de/software/ptxdist/temporary-src
ZLIB_DIR=$BUILD_DIR/zlib-1.2.3-ptx4
ZLIB_ENV=

build_zlib() {
    test -e "$STATE_DIR/zlib-1.2.3-ptx4" && return
    banner "Build $ZLIB"
    download $ZLIB_MIRROR $ZLIB
    extract $ZLIB
    apply_patches $ZLIB_DIR $ZLIB
    pushd $TOP_DIR
    cd $ZLIB_DIR
    eval $ZLIB_ENV \
	./configure --host=$TARGET_ARCH \
	    --prefix=/usr \
	    --sysconfdir=/etc || error
    make $MAKEARGS || error

    #install library to rootfs
    $INSTALL -m 644 .libs/libz.so.1.2.3 $ROOTFS_DIR/usr/lib/
    ln -sf libz.so.1.2.3 $ROOTFS_DIR/usr/lib/libz.so.1
    ln -sf libz.so.1.2.3 $ROOTFS_DIR/usr/lib/libz.so
    #install headers and library to target sysroot
    $INSTALL -m 644 .libs/libz.so.1.2.3 $TARGET_LIB/
    ln -sf libz.so.1.2.3 $TARGET_LIB/libz.so.1
    ln -sf libz.so.1.2.3 $TARGET_LIB/libz.so
    $INSTALL -m 644 zconf.h zlib.h $TARGET_INC/
    popd
    touch "$STATE_DIR/zlib-1.2.3-ptx4"
}

build_zlib
