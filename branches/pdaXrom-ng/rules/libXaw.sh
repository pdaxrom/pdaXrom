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

LIBXAW=libXaw-1.0.4.tar.bz2
LIBXAW_MIRROR=ftp://ftp.freedesktop.org/pub/xorg/individual/lib
LIBXAW_DIR=$BUILD_DIR/libXaw-1.0.4
LIBXAW_ENV=

build_libXaw() {
    test -e "$STATE_DIR/libXaw-1.0.4" && return
    banner "Build $LIBXAW"
    download $LIBXAW_MIRROR $LIBXAW
    extract $LIBXAW
    apply_patches $LIBXAW_DIR $LIBXAW
    pushd $TOP_DIR
    cd $LIBXAW_DIR
    (
    eval \
	$CROSS_CONF_ENV \
	$LIBXAW_ENV \
	./configure --host=$TARGET_ARCH \
	    --prefix=/usr \
	    --sysconfdir=/etc \
	    --disable-xaw6 \
	    --enable-xaw7 \
	    --disable-xaw8 \
	    || error
    )
    make $MAKEARGS || error

    install_sysroot_files || error
    
#    $INSTALL -D -m 644 src/.libs/libXaw8.so.8.0.0 $ROOTFS_DIR/usr/lib/libXaw8.so.8.0.0 || error
#    ln -sf libXaw8.so.8.0.0 $ROOTFS_DIR/usr/lib/libXaw8.so.8
#    ln -sf libXaw8.so.8.0.0 $ROOTFS_DIR/usr/lib/libXaw8.so
#    $STRIP $ROOTFS_DIR/usr/lib/libXaw8.so.8.0.0

    $INSTALL -D -m 644 src/.libs/libXaw7.so.7.0.0 $ROOTFS_DIR/usr/lib/libXaw7.so.7.0.0 || error
    ln -sf libXaw7.so.7.0.0 $ROOTFS_DIR/usr/lib/libXaw7.so.7
    ln -sf libXaw7.so.7.0.0 $ROOTFS_DIR/usr/lib/libXaw7.so
    $STRIP $ROOTFS_DIR/usr/lib/libXaw7.so.7.0.0

    ln -sf libXaw7.so.7 $ROOTFS_DIR/usr/lib/libXaw.so.7
    ln -sf libXaw7.so   $ROOTFS_DIR/usr/lib/libXaw.so

    popd
    touch "$STATE_DIR/libXaw-1.0.4"
}

build_libXaw
