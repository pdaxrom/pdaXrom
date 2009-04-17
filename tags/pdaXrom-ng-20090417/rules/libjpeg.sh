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

LIBJPEG=libjpeg-6b-ptx1.tar.bz2
LIBJPEG_MIRROR=http://www.pengutronix.de/software/ptxdist/temporary-src
LIBJPEG_DIR=$BUILD_DIR/libjpeg-6b-ptx1
LIBJPEG_ENV=

build_libjpeg() {
    test -e "$STATE_DIR/libjpeg-6b-ptx1" && return
    banner "Build $LIBJPEG"
    download $LIBJPEG_MIRROR $LIBJPEG
    extract $LIBJPEG
    apply_patches $LIBJPEG_DIR $LIBJPEG
    pushd $TOP_DIR
    cd $LIBJPEG_DIR
    (
    eval \
	$CROSS_CONF_ENV \
	$LIBJPEG_ENV \
	./configure --build=$BUILD_ARCH --host=$TARGET_ARCH \
	    --prefix=/usr \
	    --sysconfdir=/etc \
	    --disable-static \
	    || error
    )
    make $MAKEARGS || error

    install_sysroot_files
    
    $INSTALL -m 644 .libs/libjpeg.so.62.0.0 $ROOTFS_DIR/usr/lib/
    ln -sf libjpeg.so.62.0.0 $ROOTFS_DIR/usr/lib/libjpeg.so.62
    ln -sf libjpeg.so.62.0.0 $ROOTFS_DIR/usr/lib/libjpeg.so
    $STRIP $ROOTFS_DIR/usr/lib/libjpeg.so.62.0.0

    popd
    touch "$STATE_DIR/libjpeg-6b-ptx1"
}

build_libjpeg
