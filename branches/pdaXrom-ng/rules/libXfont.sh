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

LIBXFONT=libXfont-1.3.1.tar.bz2
LIBXFONT_MIRROR=ftp://ftp.freedesktop.org/pub/xorg/individual/lib
LIBXFONT_DIR=$BUILD_DIR/libXfont-1.3.1
LIBXFONT_ENV=

build_libXfont() {
    test -e "$STATE_DIR/libXfont-1.3.1" && return
    banner "Build $LIBXFONT"
    download $LIBXFONT_MIRROR $LIBXFONT
    extract $LIBXFONT
    apply_patches $LIBXFONT_DIR $LIBXFONT
    pushd $TOP_DIR
    cd $LIBXFONT_DIR
    (
    eval \
	$CROSS_CONF_ENV \
	$LIBXFONT_ENV \
	./configure --host=$TARGET_ARCH \
	    --prefix=/usr \
	    --sysconfdir=/etc \
	    --enable-freetype \
	    --disable-fc \
	    --enable-fontcache \
	    --enable-type1 \
	    --enable-cid \
	    --enable-speedo \
	    --enable-pcfformat \
	    --enable-bdfformat \
	    --enable-snfformat \
	    --disable-builtins \
	    || error
    )
    make $MAKEARGS || error

    install_sysroot_files || error
    
    $INSTALL -D -m 644 src/.libs/libXfont.so.1.4.1 $ROOTFS_DIR/usr/lib/libXfont.so.1.4.1 || error
    ln -sf libXfont.so.1.4.1 $ROOTFS_DIR/usr/lib/libXfont.so.1
    ln -sf libXfont.so.1.4.1 $ROOTFS_DIR/usr/lib/libXfont.so
    $STRIP $ROOTFS_DIR/usr/lib/libXfont.so.1.4.1

    popd
    touch "$STATE_DIR/libXfont-1.3.1"
}

build_libXfont
