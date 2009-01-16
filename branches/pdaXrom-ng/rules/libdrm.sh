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

LIBDRM=libdrm-2.4.4.tar.bz2
LIBDRM_MIRROR=http://dri.freedesktop.org/libdrm
LIBDRM_DIR=$BUILD_DIR/libdrm-2.4.4
LIBDRM_ENV=

build_libdrm() {
    test -e "$STATE_DIR/libdrm-2.4.1" && return
    banner "Build $LIBDRM"
    download $LIBDRM_MIRROR $LIBDRM
    extract $LIBDRM
    apply_patches $LIBDRM_DIR $LIBDRM
    pushd $TOP_DIR
    cd $LIBDRM_DIR
    (
    eval \
	$CROSS_CONF_ENV \
	$LIBDRM_ENV \
	./configure --build=$BUILD_ARCH --host=$TARGET_ARCH \
	    --prefix=/usr \
	    --sysconfdir=/etc \
	    || error
    )
    make $MAKEARGS || error

    install_sysroot_files || error
    
    $INSTALL -D -m 644 libdrm/.libs/libdrm.so.2.4.0 $ROOTFS_DIR/usr/lib/libdrm.so.2.4.0 || error
    ln -sf libdrm.so.2.4.0 $ROOTFS_DIR/usr/lib/libdrm.so.2
    ln -sf libdrm.so.2.4.0 $ROOTFS_DIR/usr/lib/libdrm.so
    $STRIP $ROOTFS_DIR/usr/lib/libdrm.so.2.4.0
    
    $INSTALL -D -m 644 libdrm/intel/.libs/libdrm_intel.so.1.0.0 $ROOTFS_DIR/usr/lib/libdrm_intel.so.1.0.0 || error
    ln -sf libdrm_intel.so.1.0.0 $ROOTFS_DIR/usr/lib/libdrm_intel.so.1
    ln -sf libdrm_intel.so.1.0.0 $ROOTFS_DIR/usr/lib/libdrm_intel.so
    $STRIP $ROOTFS_DIR/usr/lib/libdrm_intel.so.1.0.0

    popd
    touch "$STATE_DIR/libdrm-2.4.1"
}

build_libdrm
