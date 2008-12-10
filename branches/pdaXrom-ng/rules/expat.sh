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

EXPAT=expat-2.0.1.tar.gz
EXPAT_MIRROR=http://downloads.sourceforge.net/expat
EXPAT_DIR=$BUILD_DIR/expat-2.0.1
EXPAT_ENV=

build_expat() {
    test -e "$STATE_DIR/expat-2.0.1" && return
    banner "Build $EXPAT"
    download $EXPAT_MIRROR $EXPAT
    extract $EXPAT
    apply_patches $EXPAT_DIR $EXPAT
    pushd $TOP_DIR
    cd $EXPAT_DIR
    (
    eval \
	$CROSS_CONF_ENV \
	$EXPAT_ENV \
	./configure --host=$TARGET_ARCH \
	    --prefix=/usr \
	    --sysconfdir=/etc || error
    )
    make $MAKEARGS || error

    install_sysroot_files || error
    
    $INSTALL -D -m 644 .libs/libexpat.so.1.5.2 $ROOTFS_DIR/usr/lib/libexpat.so.1.5.2 || error
    ln -sf libexpat.so.1.5.2 $ROOTFS_DIR/usr/lib/libexpat.so.1
    ln -sf libexpat.so.1.5.2 $ROOTFS_DIR/usr/lib/libexpat.so
    $STRIP $ROOTFS_DIR/usr/lib/libexpat.so.1.5.2

    popd
    touch "$STATE_DIR/expat-2.0.1"
}

build_expat
