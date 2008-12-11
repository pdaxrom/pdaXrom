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

LIBXKBUI=libxkbui-1.0.2.tar.bz2
LIBXKBUI_MIRROR=ftp://ftp.freedesktop.org/pub/xorg/individual/lib
LIBXKBUI_DIR=$BUILD_DIR/libxkbui-1.0.2
LIBXKBUI_ENV=

build_libxkbui() {
    test -e "$STATE_DIR/libxkbui-1.0.2" && return
    banner "Build $LIBXKBUI"
    download $LIBXKBUI_MIRROR $LIBXKBUI
    extract $LIBXKBUI
    apply_patches $LIBXKBUI_DIR $LIBXKBUI
    pushd $TOP_DIR
    cd $LIBXKBUI_DIR
    (
    eval \
	$CROSS_CONF_ENV \
	$LIBXKBUI_ENV \
	./configure --host=$TARGET_ARCH \
	    --prefix=/usr \
	    --sysconfdir=/etc \
	    || error
    )
    make $MAKEARGS || error

    install_sysroot_files || error
    
    $INSTALL -D -m 644 src/.libs/libxkbui.so.1.0.0 $ROOTFS_DIR/usr/lib/libxkbui.so.1.0.0 || error
    ln -sf libxkbui.so.1.0.0 $ROOTFS_DIR/usr/lib/libxkbui.so.1
    ln -sf libxkbui.so.1.0.0 $ROOTFS_DIR/usr/lib/libxkbui.so
    $STRIP $ROOTFS_DIR/usr/lib/libxkbui.so.1.0.0

    popd
    touch "$STATE_DIR/libxkbui-1.0.2"
}

build_libxkbui
