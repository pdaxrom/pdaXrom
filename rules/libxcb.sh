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

LIBXCB_VERSION=1.2
LIBXCB=libxcb-${LIBXCB_VERSION}.tar.bz2
LIBXCB_MIRROR=http://xcb.freedesktop.org/dist
LIBXCB_DIR=$BUILD_DIR/libxcb-${LIBXCB_VERSION}
LIBXCB_ENV=

build_libxcb() {
    test -e "$STATE_DIR/libxcb-${LIBXCB_VERSION}" && return
    banner "Build $LIBXCB"
    download $LIBXCB_MIRROR $LIBXCB
    extract $LIBXCB
    apply_patches $LIBXCB_DIR $LIBXCB
    pushd $TOP_DIR
    cd $LIBXCB_DIR
    (
    eval \
	$CROSS_CONF_ENV \
	$LIBXCB_ENV \
	./configure --build=$BUILD_ARCH --host=$TARGET_ARCH \
	    --prefix=/usr \
	    --disable-build-docs \
	    --sysconfdir=/etc || error
    )
    make $MAKEARGS || error

    install_sysroot_files || error
    
    for f in composite damage dpms glx randr record render res screensaver shape shm \
	    sync xevie xf86dri xfixes xinerama xprint xtest xv xvmc ; do
	$INSTALL -D -m 644 src/.libs/libxcb-${f}.so.0.0.0 $ROOTFS_DIR/usr/lib/libxcb-${f}.so.0.0.0 || error
	ln -sf libxcb-${f}.so.0.0.0 $ROOTFS_DIR/usr/lib/libxcb-${f}.so.0
	ln -sf libxcb-${f}.so.0.0.0 $ROOTFS_DIR/usr/lib/libxcb-${f}.so
	$STRIP $ROOTFS_DIR/usr/lib/libxcb-${f}.so.0.0.0
    done

    $INSTALL -D -m 644 src/.libs/libxcb.so.1.1.0 $ROOTFS_DIR/usr/lib/libxcb.so.1.1.0 || error
    ln -sf libxcb.so.1.1.0 $ROOTFS_DIR/usr/lib/libxcb.so.1
    ln -sf libxcb.so.1.1.0 $ROOTFS_DIR/usr/lib/libxcb.so
    $STRIP $ROOTFS_DIR/usr/lib/libxcb.so.1.1.0

    popd
    touch "$STATE_DIR/libxcb-${LIBXCB_VERSION}"
}

build_libxcb
