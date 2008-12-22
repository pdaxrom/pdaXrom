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

LIBXMU=libXmu-1.0.4.tar.bz2
LIBXMU_MIRROR=ftp://ftp.freedesktop.org/pub/xorg/individual/lib
LIBXMU_DIR=$BUILD_DIR/libXmu-1.0.4
LIBXMU_ENV=

build_libXmu() {
    test -e "$STATE_DIR/libXmu-1.0.3" && return
    banner "Build $LIBXMU"
    download $LIBXMU_MIRROR $LIBXMU
    extract $LIBXMU
    apply_patches $LIBXMU_DIR $LIBXMU
    pushd $TOP_DIR
    cd $LIBXMU_DIR
    (
    eval \
	$CROSS_CONF_ENV \
	$LIBXMU_ENV \
	./configure --build=$BUILD_ARCH --host=$TARGET_ARCH \
	    --prefix=/usr \
	    --sysconfdir=/etc || error
    )
    make $MAKEARGS || error

    install_sysroot_files || error
    
    $INSTALL -D -m 644 src/.libs/libXmu.so.6.2.0 $ROOTFS_DIR/usr/lib/libXmu.so.6.2.0 || error
    ln -sf libXmu.so.6.2.0 $ROOTFS_DIR/usr/lib/libXmu.so.6
    ln -sf libXmu.so.6.2.0 $ROOTFS_DIR/usr/lib/libXmu.so
    $STRIP $ROOTFS_DIR/usr/lib/libXmu.so.6.2.0

    $INSTALL -D -m 644 src/.libs/libXmuu.so.1.0.0 $ROOTFS_DIR/usr/lib/libXmuu.so.1.0.0 || error
    ln -sf libXmuu.so.1.0.0 $ROOTFS_DIR/usr/lib/libXmuu.so.1
    ln -sf libXmuu.so.1.0.0 $ROOTFS_DIR/usr/lib/libXmuu.so
    $STRIP $ROOTFS_DIR/usr/lib/libXmuu.so.1.0.0

    popd
    touch "$STATE_DIR/libXmu-1.0.3"
}

build_libXmu
