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

LIBSM=libSM-1.0.3.tar.bz2
LIBSM_MIRROR=ftp://ftp.freedesktop.org/pub/xorg/individual/lib
LIBSM_DIR=$BUILD_DIR/libSM-1.0.3
LIBSM_ENV=

build_libSM() {
    test -e "$STATE_DIR/libSM-1.0.3" && return
    banner "Build $LIBSM"
    download $LIBSM_MIRROR $LIBSM
    extract $LIBSM
    apply_patches $LIBSM_DIR $LIBSM
    pushd $TOP_DIR
    cd $LIBSM_DIR
    (
    eval \
	$CROSS_CONF_ENV \
	$LIBSM_ENV \
	./configure --build=$BUILD_ARCH --host=$TARGET_ARCH \
	    --prefix=/usr \
	    --sysconfdir=/etc || error
    )
    make $MAKEARGS || error

    install_sysroot_files || error
    
    $INSTALL -D -m 644 src/.libs/libSM.so.6.0.0 $ROOTFS_DIR/usr/lib/libSM.so.6.0.0 || error
    ln -sf libSM.so.6.0.0 $ROOTFS_DIR/usr/lib/libSM.so.6
    ln -sf libSM.so.6.0.0 $ROOTFS_DIR/usr/lib/libSM.so
    $STRIP $ROOTFS_DIR/usr/lib/libSM.so.6.0.0

    popd
    touch "$STATE_DIR/libSM-1.0.3"
}

build_libSM
