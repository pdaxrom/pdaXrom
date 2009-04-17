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

LIBSOUP=libsoup-2.25.3.tar.bz2
LIBSOUP_MIRROR=http://ftp.gnome.org/pub/GNOME/sources/libsoup/2.25
LIBSOUP_DIR=$BUILD_DIR/libsoup-2.25.3
LIBSOUP_ENV="$CROSS_ENV_AC"

build_libsoup() {
    test -e "$STATE_DIR/libsoup.installed" && return
    banner "Build libsoup"
    download $LIBSOUP_MIRROR $LIBSOUP
    extract $LIBSOUP
    apply_patches $LIBSOUP_DIR $LIBSOUP
    pushd $TOP_DIR
    cd $LIBSOUP_DIR
    (
    eval \
	$CROSS_CONF_ENV \
	$LIBSOUP_ENV \
	./configure --build=$BUILD_ARCH --host=$TARGET_ARCH \
	    --prefix=/usr \
	    --sysconfdir=/etc \
	    --without-gnome \
	    || error
    ) || error "configure"
    
    make $MAKEARGS || error

    install_sysroot_files || error
    
    $INSTALL -D -m 644 libsoup/.libs/libsoup-2.4.so.1.2.0 $ROOTFS_DIR/usr/lib/libsoup-2.4.so.1.2.0 || error
    ln -sf libsoup-2.4.so.1.2.0 $ROOTFS_DIR/usr/lib/libsoup-2.4.so.1
    ln -sf libsoup-2.4.so.1.2.0 $ROOTFS_DIR/usr/lib/libsoup-2.4.so
    $STRIP $ROOTFS_DIR/usr/lib/libsoup-2.4.so.1.2.0

    popd
    touch "$STATE_DIR/libsoup.installed"
}

build_libsoup
