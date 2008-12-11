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

LIBXPM=libXpm-3.5.7.tar.bz2
LIBXPM_MIRROR=ftp://ftp.freedesktop.org/pub/xorg/individual/lib
LIBXPM_DIR=$BUILD_DIR/libXpm-3.5.7
LIBXPM_ENV=

build_libXpm() {
    test -e "$STATE_DIR/libXpm-3.5.7" && return
    banner "Build $LIBXPM"
    download $LIBXPM_MIRROR $LIBXPM
    extract $LIBXPM
    apply_patches $LIBXPM_DIR $LIBXPM
    pushd $TOP_DIR
    cd $LIBXPM_DIR
    (
    eval \
	$CROSS_CONF_ENV \
	$LIBXPM_ENV \
	./configure --host=$TARGET_ARCH \
	    --prefix=/usr \
	    --sysconfdir=/etc || error
    )
    make $MAKEARGS || error

    install_sysroot_files || error
    
    $INSTALL -D -m 644 src/.libs/libXpm.so.4.11.0 $ROOTFS_DIR/usr/lib/libXpm.so.4.11.0 || error
    ln -sf libXpm.so.4.11.0 $ROOTFS_DIR/usr/lib/libXpm.so.4
    ln -sf libXpm.so.4.11.0 $ROOTFS_DIR/usr/lib/libXpm.so
    $STRIP $ROOTFS_DIR/usr/lib/libXpm.so.4.11.0

    popd
    touch "$STATE_DIR/libXpm-3.5.7"
}

build_libXpm
