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

LIBXINERAMA=libXinerama-1.0.3.tar.bz2
LIBXINERAMA_MIRROR=ftp://ftp.freedesktop.org/pub/xorg/individual/lib
LIBXINERAMA_DIR=$BUILD_DIR/libXinerama-1.0.3
LIBXINERAMA_ENV=

build_libXinerama() {
    test -e "$STATE_DIR/libXinerama-1.0.2" && return
    banner "Build $LIBXINERAMA"
    download $LIBXINERAMA_MIRROR $LIBXINERAMA
    extract $LIBXINERAMA
    apply_patches $LIBXINERAMA_DIR $LIBXINERAMA
    pushd $TOP_DIR
    cd $LIBXINERAMA_DIR
    (
    eval \
	$CROSS_CONF_ENV \
	$LIBXINERAMA_ENV \
	./configure --host=$TARGET_ARCH \
	    --prefix=/usr \
	    --sysconfdir=/etc \
	    --disable-malloc0returnsnull \
	    || error
    )
    make $MAKEARGS || error

    install_sysroot_files || error
    
    $INSTALL -D -m 644 src/.libs/libXinerama.so.1.0.0 $ROOTFS_DIR/usr/lib/libXinerama.so.1.0.0 || error
    ln -sf libXinerama.so.1.0.0 $ROOTFS_DIR/usr/lib/libXinerama.so.1
    ln -sf libXinerama.so.1.0.0 $ROOTFS_DIR/usr/lib/libXinerama.so
    $STRIP $ROOTFS_DIR/usr/lib/libXinerama.so.1.0.0

    popd
    touch "$STATE_DIR/libXinerama-1.0.2"
}

build_libXinerama
