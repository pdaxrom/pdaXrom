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

LIBX11=libX11-1.1.5.tar.bz2
LIBX11_MIRROR=ftp://ftp.freedesktop.org/pub/xorg/individual/lib
LIBX11_DIR=$BUILD_DIR/libX11-1.1.5
LIBX11_ENV=

build_libX11() {
    test -e "$STATE_DIR/libX11-1.1.3" && return
    banner "Build $LIBX11"
    download $LIBX11_MIRROR $LIBX11
    extract $LIBX11
    apply_patches $LIBX11_DIR $LIBX11
    pushd $TOP_DIR
    cd $LIBX11_DIR
    (
    eval \
	$CROSS_CONF_ENV \
	$LIBX11_ENV \
	./configure --build=$BUILD_ARCH --host=$TARGET_ARCH \
	    --prefix=/usr \
	    --sysconfdir=/etc \
	    --disable-malloc0returnsnull \
	    --disable-man-pages \
	    || error
    )

    make -C src/util $MAKEARGS || error
    
    $HOST_CC -I$TARGET_INC src/util/makekeys.c -o src/util/makekeys || error

    make $MAKEARGS || error

    install_sysroot_files || error

    $INSTALL -D -m 644 src/.libs/libX11.so.6.2.0 $ROOTFS_DIR/usr/lib/libX11.so.6.2.0
    ln -sf libX11.so.6.2.0 $ROOTFS_DIR/usr/lib/libX11.so.6
    ln -sf libX11.so.6.2.0 $ROOTFS_DIR/usr/lib/libX11.so
    $STRIP $ROOTFS_DIR/usr/lib/libX11.so.6.2.0
    
    $INSTALL -D -m 644 src/.libs/libX11-xcb.so.1.0.0 $ROOTFS_DIR/usr/lib/libX11-xcb.so.1.0.0
    ln -sf libX11-xcb.so.1.0.0 $ROOTFS_DIR/usr/lib/libX11-xcb.so.1
    ln -sf libX11-xcb.so.1.0.0 $ROOTFS_DIR/usr/lib/libX11-xcb.so
    $STRIP $ROOTFS_DIR/usr/lib/libX11-xcb.so.1.0.0

    $INSTALL -D -m 644 nls/locale.alias $ROOTFS_DIR/usr/share/X11/locale/locale.alias
    $INSTALL -D -m 644 nls/locale.dir	$ROOTFS_DIR/usr/share/X11/locale/locale.dir
    $INSTALL -D -m 644 nls/compose.dir	$ROOTFS_DIR/usr/share/X11/locale/compose.dir
    $INSTALL -D -m 644 nls/C/Compose	$ROOTFS_DIR/usr/share/X11/locale/C/Compose
    $INSTALL -D -m 644 nls/C/XI18N_OBJS	$ROOTFS_DIR/usr/share/X11/locale/C/XI18N_OBJS
    $INSTALL -D -m 644 nls/C/XLC_LOCALE	$ROOTFS_DIR/usr/share/X11/locale/C/XLC_LOCALE

    # locales

    for f in iso8859-1 iso8859-15 ; do
	$INSTALL -D -m 644 nls/${f}/Compose	$ROOTFS_DIR/usr/share/X11/locale/${f}/Compose
	$INSTALL -D -m 644 nls/${f}/XI18N_OBJS	$ROOTFS_DIR/usr/share/X11/locale/${f}/XI18N_OBJS
	$INSTALL -D -m 644 nls/${f}/XLC_LOCALE	$ROOTFS_DIR/usr/share/X11/locale/${f}/XLC_LOCALE
    done

    $INSTALL -D -m 644 src/XKeysymDB	$ROOTFS_DIR/usr/share/X11/XKeysymDB
    $INSTALL -D -m 644 src/XErrorDB	$ROOTFS_DIR/usr/share/X11/XErrorDB

    popd
    touch "$STATE_DIR/libX11-1.1.3"
}

build_libX11
