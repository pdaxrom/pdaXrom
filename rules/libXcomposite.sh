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

LIBXCOMPOSITE=libXcomposite-0.4.0.tar.bz2
LIBXCOMPOSITE_MIRROR=ftp://ftp.freedesktop.org/pub/xorg/individual/lib
LIBXCOMPOSITE_DIR=$BUILD_DIR/libXcomposite-0.4.0
LIBXCOMPOSITE_ENV=

build_libXcomposite() {
    test -e "$STATE_DIR/libXcomposite-0.4.0" && return
    banner "Build $LIBXCOMPOSITE"
    download $LIBXCOMPOSITE_MIRROR $LIBXCOMPOSITE
    extract $LIBXCOMPOSITE
    apply_patches $LIBXCOMPOSITE_DIR $LIBXCOMPOSITE
    pushd $TOP_DIR
    cd $LIBXCOMPOSITE_DIR
    (
    eval \
	$CROSS_CONF_ENV \
	$LIBXCOMPOSITE_ENV \
	./configure --build=$BUILD_ARCH --host=$TARGET_ARCH \
	    --prefix=/usr \
	    --sysconfdir=/etc \
	    || error
    )
    make $MAKEARGS || error

    install_sysroot_files || error
    
    $INSTALL -D -m 644 src/.libs/libXcomposite.so.1.0.0 $ROOTFS_DIR/usr/lib/libXcomposite.so.1.0.0 || error
    ln -sf libXcomposite.so.1.0.0 $ROOTFS_DIR/usr/lib/libXcomposite.so.1
    ln -sf libXcomposite.so.1.0.0 $ROOTFS_DIR/usr/lib/libXcomposite.so
    $STRIP $ROOTFS_DIR/usr/lib/libXcomposite.so.1.0.0

    popd
    touch "$STATE_DIR/libXcomposite-0.4.0"
}

build_libXcomposite
