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

GTK2_VERSION=2.16.0
GTK2=gtk+-${GTK2_VERSION}.tar.bz2
GTK2_MIRROR=http://ftp.acc.umu.se/pub/gnome/sources/gtk+/2.16
GTK2_DIR=$BUILD_DIR/gtk+-${GTK2_VERSION}
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
	./configure --build=$BUILD_ARCH --host=$TARGET_ARCH \
	    --prefix=/usr \
	    --sysconfdir=/etc \
	    --x-includes=$TARGET_INC \
	    --x-libraries=$TARGET_LIB \
	    --enable-static \
	    --enable-explicit-deps=yes \
	    --disable-glibtest \
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

    $INSTALL -D -m 644 modules/other/gail/libgail-util/.libs/libgailutil.so.18.0.1 $ROOTFS_DIR/usr/lib/libgailutil.so.18.0.1 || error
    ln -sf libgailutil.so.18.0.1 $ROOTFS_DIR/usr/lib/libgailutil.so.18
    ln -sf libgailutil.so.18.0.1 $ROOTFS_DIR/usr/lib/libgailutil.so
    $STRIP $ROOTFS_DIR/usr/lib/libgailutil.so.18.0.1
    
    $INSTALL -D -m 644 gdk/.libs/libgdk-x11-2.0.so.0.1600.0 $ROOTFS_DIR/usr/lib/libgdk-x11-2.0.so.0.1600.0 || error
    ln -sf libgdk-x11-2.0.so.0.1600.0 $ROOTFS_DIR/usr/lib/libgdk-x11-2.0.so.0
    ln -sf libgdk-x11-2.0.so.0.1600.0 $ROOTFS_DIR/usr/lib/libgdk-x11-2.0.so
    $STRIP $ROOTFS_DIR/usr/lib/libgdk-x11-2.0.so.0.1600.0
    
    $INSTALL -D -m 644 gtk/.libs/libgtk-x11-2.0.so.0.1600.0 $ROOTFS_DIR/usr/lib/libgtk-x11-2.0.so.0.1600.0 || error
    ln -sf libgtk-x11-2.0.so.0.1600.0 $ROOTFS_DIR/usr/lib/libgtk-x11-2.0.so.0
    ln -sf libgtk-x11-2.0.so.0.1600.0 $ROOTFS_DIR/usr/lib/libgtk-x11-2.0.so
    $STRIP $ROOTFS_DIR/usr/lib/libgtk-x11-2.0.so.0.1600.0

    $INSTALL -D -m 644 contrib/gdk-pixbuf-xlib/.libs/libgdk_pixbuf_xlib-2.0.so.0.1600.0 $ROOTFS_DIR/usr/lib/libgdk_pixbuf_xlib-2.0.so.0.1600.0 || error
    ln -sf libgdk_pixbuf_xlib-2.0.so.0.1600.0 $ROOTFS_DIR/usr/lib/libgdk_pixbuf_xlib-2.0.so.0
    ln -sf libgdk_pixbuf_xlib-2.0.so.0.1600.0 $ROOTFS_DIR/usr/lib/libgdk_pixbuf_xlib-2.0.so
    $STRIP $ROOTFS_DIR/usr/lib/libgdk_pixbuf_xlib-2.0.so.0.1600.0
    
    $INSTALL -D -m 644 gdk-pixbuf/.libs/libgdk_pixbuf-2.0.so.0.1600.0 $ROOTFS_DIR/usr/lib/libgdk_pixbuf-2.0.so.0.1600.0 || error
    ln -sf libgdk_pixbuf-2.0.so.0.1600.0 $ROOTFS_DIR/usr/lib/libgdk_pixbuf-2.0.so.0
    ln -sf libgdk_pixbuf-2.0.so.0.1600.0 $ROOTFS_DIR/usr/lib/libgdk_pixbuf-2.0.so
    $STRIP $ROOTFS_DIR/usr/lib/libgdk_pixbuf-2.0.so.0.1600.0

    find modules/engines/ -name "*.so" -type f | while read f; do
	$INSTALL -D -m 644 $f $ROOTFS_DIR/usr/lib/gtk-2.0/2.10.0/engines/${f/*\/} || error "$f"
	$STRIP $ROOTFS_DIR/usr/lib/gtk-2.0/2.10.0/engines/${f/*\/}
    done

    find modules/input/ -name "*.so" -type f | while read f; do
	$INSTALL -D -m 644 $f $ROOTFS_DIR/usr/lib/gtk-2.0/2.10.0/immodules/${f/*\/} || error "$f"
	$STRIP $ROOTFS_DIR/usr/lib/gtk-2.0/2.10.0/immodules/${f/*\/}
    done

    find modules/printbackends/ -name "*.so" -type f | while read f; do
	$INSTALL -D -m 644 $f $ROOTFS_DIR/usr/lib/gtk-2.0/2.10.0/printbackends/${f/*\/} || error "$f"
	$STRIP $ROOTFS_DIR/usr/lib/gtk-2.0/2.10.0/printbackends/${f/*\/}
    done

    find gdk-pixbuf/.libs/ -name "*.so" -type f | while read f; do
	$INSTALL -D -m 644 $f $ROOTFS_DIR/usr/lib/gtk-2.0/2.10.0/loaders/${f/*\/} || error "$f"
	$STRIP $ROOTFS_DIR/usr/lib/gtk-2.0/2.10.0/loaders/${f/*\/}
    done

    $INSTALL -D -m 644 modules/other/gail/.libs/libgail.so $ROOTFS_DIR/usr/lib/gtk-2.0/modules/libgail.so || error
    $STRIP $ROOTFS_DIR/usr/lib/gtk-2.0/modules/libgail.so

    $INSTALL -D -m 644 modules/other/gail/tests/.libs/libferret.so $ROOTFS_DIR/usr/lib/gtk-2.0/modules/libferret.so || error
    $STRIP $ROOTFS_DIR/usr/lib/gtk-2.0/modules/libferret.so

    $INSTALL -D -m 755 gdk-pixbuf/.libs/gdk-pixbuf-query-loaders $ROOTFS_DIR/usr/bin/gdk-pixbuf-query-loaders || error
    $STRIP $ROOTFS_DIR/usr/bin/gdk-pixbuf-query-loaders
    
    $INSTALL -D -m 755 gtk/.libs/gtk-query-immodules-2.0 $ROOTFS_DIR/usr/bin/gtk-query-immodules-2.0 || error
    $STRIP $ROOTFS_DIR/usr/bin/gtk-query-immodules-2.0

    $INSTALL -D -m 755 gtk/.libs/gtk-update-icon-cache $ROOTFS_DIR/usr/bin/gtk-update-icon-cache || error
    $STRIP $ROOTFS_DIR/usr/bin/gtk-update-icon-cache

    $INSTALL -D -m 644 modules/input/im-multipress.conf $ROOTFS_DIR/etc/gtk-2.0/im-multipress.conf || error

    $INSTALL -D -m 755 $GENERICFS_DIR/etc/init.d/gtk $ROOTFS_DIR/etc/init.d/gtk || error
    install_rc_start gtk 91

    popd
    touch "$STATE_DIR/gtk2.installed"
}

build_gtk2
