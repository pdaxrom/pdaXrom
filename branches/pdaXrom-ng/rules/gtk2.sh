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

GTK2=gtk+-2.14.6.tar.bz2
GTK2_MIRROR=http://ftp.acc.umu.se/pub/gnome/sources/gtk+/2.14
GTK2_DIR=$BUILD_DIR/gtk+-2.14.6
GTK2_ENV="$CROSS_ENV_AC gio_can_sniff=yes"
# ac_cv_path_CUPS_CONFIG=no

GTK2_LOADERS="png,gif,ico,ani,jpeg,pnm,xpm,pcx"

build_gtk2() {
    test -e "$STATE_DIR/gtk2.installed" && return
    banner "Build gtk2"
    download $GTK2_MIRROR $GTK2
    extract $GTK2
    apply_patches $GTK2_DIR $GTK2
    pushd $TOP_DIR
    cd $GTK2_DIR
    (
    eval \
	$CROSS_CONF_ENV \
	$GTK2_ENV \
	./configure --host=$TARGET_ARCH \
	    --prefix=/usr \
	    --sysconfdir=/etc \
	    --x-includes=$TARGET_INC \
	    --x-libraries=$TARGET_LIB \
	    --enable-static \
	    --enable-explicit-deps=yes \
	    --disable-glibtest \
	    --disable-modules \
	    --disable-cups \
	    --with-included-loaders="$GTK2_LOADERS" \
	    --without-libtiff \
	    --without-libjasper \
	    --with-gdktarget=x11 \
	    --enable-gtk-doc=no \
	    --enable-man=no
    ) || error "configure"
    
    make $MAKEARGS || error

    install_sysroot_files || error
    
    $INSTALL -D -m 644 gdk/.libs/libgdk-x11-2.0.so.0.1400.6 $ROOTFS_DIR/usr/lib/libgdk-x11-2.0.so.0.1400.6 || error
    ln -sf libgdk-x11-2.0.so.0.1400.6 $ROOTFS_DIR/usr/lib/libgdk-x11-2.0.so.0
    ln -sf libgdk-x11-2.0.so.0.1400.6 $ROOTFS_DIR/usr/lib/libgdk-x11-2.0.so
    $STRIP $ROOTFS_DIR/usr/lib/libgdk-x11-2.0.so.0.1400.6
    
    $INSTALL -D -m 644 gtk/.libs/libgtk-x11-2.0.so.0.1400.6 $ROOTFS_DIR/usr/lib/libgtk-x11-2.0.so.0.1400.6 || error
    ln -sf libgtk-x11-2.0.so.0.1400.6 $ROOTFS_DIR/usr/lib/libgtk-x11-2.0.so.0
    ln -sf libgtk-x11-2.0.so.0.1400.6 $ROOTFS_DIR/usr/lib/libgtk-x11-2.0.so
    $STRIP $ROOTFS_DIR/usr/lib/libgtk-x11-2.0.so.0.1400.6

    $INSTALL -D -m 644 contrib/gdk-pixbuf-xlib/.libs/libgdk_pixbuf_xlib-2.0.so.0.1400.6 $ROOTFS_DIR/usr/lib/libgdk_pixbuf_xlib-2.0.so.0.1400.6 || error
    ln -sf libgdk_pixbuf_xlib-2.0.so.0.1400.6 $ROOTFS_DIR/usr/lib/libgdk_pixbuf_xlib-2.0.so.0
    ln -sf libgdk_pixbuf_xlib-2.0.so.0.1400.6 $ROOTFS_DIR/usr/lib/libgdk_pixbuf_xlib-2.0.so
    $STRIP $ROOTFS_DIR/usr/lib/libgdk_pixbuf_xlib-2.0.so.0.1400.6
    
    $INSTALL -D -m 644 gdk-pixbuf/.libs/libgdk_pixbuf-2.0.so.0.1400.6 $ROOTFS_DIR/usr/lib/libgdk_pixbuf-2.0.so.0.1400.6 || error
    ln -sf libgdk_pixbuf-2.0.so.0.1400.6 $ROOTFS_DIR/usr/lib/libgdk_pixbuf-2.0.so.0
    ln -sf libgdk_pixbuf-2.0.so.0.1400.6 $ROOTFS_DIR/usr/lib/libgdk_pixbuf-2.0.so
    $STRIP $ROOTFS_DIR/usr/lib/libgdk_pixbuf-2.0.so.0.1400.6

    popd
    touch "$STATE_DIR/gtk2.installed"
}

build_gtk2
