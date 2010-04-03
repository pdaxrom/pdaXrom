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

BZIP2=bzip2-1.0.5.tar.gz
BZIP2_MIRROR=http://www.bzip.org/1.0.5
BZIP2_DIR=$BUILD_DIR/bzip2-1.0.5
BZIP2_ENV="$CROSS_ENV_AC"

build_bzip2() {
    test -e "$STATE_DIR/bzip2.installed" && return
    banner "Build bzip2"
    download $BZIP2_MIRROR $BZIP2
    extract $BZIP2
    apply_patches $BZIP2_DIR $BZIP2
    pushd $TOP_DIR
    cd $BZIP2_DIR
    
    make $MAKEARGS \
	-f Makefile-libbz2_so \
	CC=${CROSS}gcc \
	|| error

    $INSTALL -D -m 644 bzlib.h $TARGET_INC/bzlib.h || error
    $INSTALL -D -m 644 libbz2.so.1.0.4 $TARGET_LIB/libbz2.so.1.0.4 || error
    ln -sf libbz2.so.1.0.4 $TARGET_LIB/libbz2.so.1.0
    ln -sf libbz2.so.1.0.4 $TARGET_LIB/libbz2.so.1
    ln -sf libbz2.so.1.0.4 $TARGET_LIB/libbz2.so

    $INSTALL -D -m 644 libbz2.so.1.0.4 $ROOTFS_DIR/usr/lib/libbz2.so.1.0.4 || error
    ln -sf libbz2.so.1.0.4 $ROOTFS_DIR/usr/lib/libbz2.so.1.0
    ln -sf libbz2.so.1.0.4 $ROOTFS_DIR/usr/lib/libbz2.so.1
    ln -sf libbz2.so.1.0.4 $ROOTFS_DIR/usr/lib/libbz2.so
    $STRIP $ROOTFS_DIR/usr/lib/libbz2.so.1.0.4
    
    $INSTALL -D -m 755 bzip2-shared $ROOTFS_DIR/usr/bin/bzip2 || error
    $STRIP $ROOTFS_DIR/usr/bin/bzip2
    ln -sf bzip2 $ROOTFS_DIR/usr/bin/bzcat

    popd
    touch "$STATE_DIR/bzip2.installed"
}

build_bzip2
