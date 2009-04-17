#
# packet template
#
# Copyright (C) 2009 by Alexander Chukov <sash@pdaXrom.org>
#          
# See CREDITS for details about who has contributed to this project.
#
# For further information about the pdaXrom project and license conditions
# see the README file.
#

LIBRSVG_VERSION=2.22.3
LIBRSVG=librsvg-${LIBRSVG_VERSION}.tar.bz2
LIBRSVG_MIRROR=http://ftp.gnome.org/pub/GNOME/sources/librsvg/2.22
LIBRSVG_DIR=$BUILD_DIR/librsvg-${LIBRSVG_VERSION}
LIBRSVG_ENV="$CROSS_ENV_AC"

build_librsvg() {
    test -e "$STATE_DIR/librsvg.installed" && return
    banner "Build librsvg"
    download $LIBRSVG_MIRROR $LIBRSVG
    extract $LIBRSVG
    apply_patches $LIBRSVG_DIR $LIBRSVG
    pushd $TOP_DIR
    cd $LIBRSVG_DIR
    (
    eval \
	$CROSS_CONF_ENV \
	$LIBRSVG_ENV \
	./configure --build=$BUILD_ARCH --host=$TARGET_ARCH \
	    --prefix=/usr \
	    --sysconfdir=/etc \
	    --with-svgz \
	    --with-croco \
	    --disable-mozilla-plugin \
	    --disable-gtk-doc \
	    || error
    ) || error "configure"
    
    make $MAKEARGS || error

    install_sysroot_files || error

    $INSTALL -D -m 644 .libs/librsvg-2.so.2.22.3 $ROOTFS_DIR/usr/lib/librsvg-2.so.2.22.3 || error
    ln -sf librsvg-2.so.2.22.3 $ROOTFS_DIR/usr/lib/librsvg-2.so.2
    ln -sf librsvg-2.so.2.22.3 $ROOTFS_DIR/usr/lib/librsvg-2.so
    $STRIP $ROOTFS_DIR/usr/lib/librsvg-2.so.2.22.3

    $INSTALL -D -m 644 gdk-pixbuf-loader/.libs/svg_loader.so $ROOTFS_DIR/usr/lib/gtk-2.0/2.10.0/loaders/svg_loader.so || error
    $STRIP $ROOTFS_DIR/usr/lib/gtk-2.0/2.10.0/loaders/svg_loader.so
    
    $INSTALL -D -m 644 gtk-engine/.libs/libsvg.so $ROOTFS_DIR/usr/lib/gtk-2.0/2.10.0/engines/libsvg.so || error
    $STRIP $ROOTFS_DIR/usr/lib/gtk-2.0/2.10.0/engines/libsvg.so

    popd
    touch "$STATE_DIR/librsvg.installed"
}

build_librsvg
