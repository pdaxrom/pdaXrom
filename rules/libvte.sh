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

LIBVTE=vte-0.19.4.tar.bz2
LIBVTE_MIRROR=http://ftp.gnome.org/pub/GNOME/sources/vte/0.19
LIBVTE_DIR=$BUILD_DIR/vte-0.19.4
LIBVTE_ENV="$CROSS_ENV_AC"

build_libvte() {
    test -e "$STATE_DIR/libvte.installed" && return
    banner "Build libvte"
    download $LIBVTE_MIRROR $LIBVTE
    extract $LIBVTE
    apply_patches $LIBVTE_DIR $LIBVTE
    pushd $TOP_DIR
    cd $LIBVTE_DIR
    (
    eval \
	$CROSS_CONF_ENV \
	$LIBVTE_ENV \
	./configure --build=$BUILD_ARCH --host=$TARGET_ARCH \
	    --prefix=/usr \
	    --sysconfdir=/etc \
	    --disable-glade \
	    --disable-gtk-doc \
	    --disable-python \
	    || error
    ) || error "configure"
    
    make $MAKEARGS || error

    install_sysroot_files || error
    
    $INSTALL -D -m 644 src/.libs/libvte.so.9.4.3 $ROOTFS_DIR/usr/lib/libvte.so.9.4.3 || error
    ln -sf libvte.so.9.4.3 $ROOTFS_DIR/usr/lib/libvte.so.9
    ln -sf libvte.so.9.4.3 $ROOTFS_DIR/usr/lib/libvte.so
    $STRIP $ROOTFS_DIR/usr/lib/libvte.so.9.4.3

    $INSTALL -D -m 644 termcaps/xterm.baseline $ROOTFS_DIR/etc/termcap || error

    popd
    touch "$STATE_DIR/libvte.installed"
}

build_libvte
