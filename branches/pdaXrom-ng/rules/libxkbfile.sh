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

LIBXKBFILE=libxkbfile-1.0.4.tar.bz2
LIBXKBFILE_MIRROR=ftp://ftp.freedesktop.org/pub/xorg/X11R7.3/src/lib
LIBXKBFILE_DIR=$BUILD_DIR/libxkbfile-1.0.4
LIBXKBFILE_ENV=

build_libxkbfile() {
    test -e "$STATE_DIR/libxkbfile-1.0.4" && return
    banner "Build $LIBXKBFILE"
    download $LIBXKBFILE_MIRROR $LIBXKBFILE
    extract $LIBXKBFILE
    apply_patches $LIBXKBFILE_DIR $LIBXKBFILE
    pushd $TOP_DIR
    cd $LIBXKBFILE_DIR
    (
    eval \
	$CROSS_CONF_ENV \
	$LIBXKBFILE_ENV \
	./configure --host=$TARGET_ARCH \
	    --prefix=/usr \
	    --sysconfdir=/etc \
	    || error
    )
    make $MAKEARGS || error

    install_sysroot_files || error
    
    $INSTALL -D -m 644 src/.libs/libxkbfile.so.1.0.2 $ROOTFS_DIR/usr/lib/libxkbfile.so.1.0.2 || error
    ln -sf libxkbfile.so.1.0.2 $ROOTFS_DIR/usr/lib/libxkbfile.so.1
    ln -sf libxkbfile.so.1.0.2 $ROOTFS_DIR/usr/lib/libxkbfile.so
    $STRIP $ROOTFS_DIR/usr/lib/libxkbfile.so.1.0.2

    popd
    touch "$STATE_DIR/libxkbfile-1.0.4"
}

build_libxkbfile
