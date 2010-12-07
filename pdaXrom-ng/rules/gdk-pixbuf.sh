#
# packet template
#
# Copyright (C) 2010 by Alexander Chukov <sash@pdaXrom.org>
#
# See CREDITS for details about who has contributed to this project.
#
# For further information about the pdaXrom project and license conditions
# see the README file.
#

GDK_PIXBUF_VERSION=2.22.1
GDK_PIXBUF=gdk-pixbuf-${GDK_PIXBUF_VERSION}.tar.bz2
GDK_PIXBUF_MIRROR=http://ftp.acc.umu.se/pub/gnome/sources/gdk-pixbuf/2.22
GDK_PIXBUF_DIR=$BUILD_DIR/gdk-pixbuf-${GDK_PIXBUF_VERSION}
GDK_PIXBUF_ENV="$CROSS_ENV_AC gio_can_sniff=yes"

build_gdk_pixbuf() {
    test -e "$STATE_DIR/gdk_pixbuf.installed" && return
    banner "Build gdk-pixbuf"
    download $GDK_PIXBUF_MIRROR $GDK_PIXBUF
    extract $GDK_PIXBUF
    apply_patches $GDK_PIXBUF_DIR $GDK_PIXBUF
    pushd $TOP_DIR
    cd $GDK_PIXBUF_DIR
    (
    eval \
	$CROSS_CONF_ENV \
	$GDK_PIXBUF_ENV \
	./configure --build=$BUILD_ARCH --host=$TARGET_ARCH \
	    --prefix=/usr \
	    --sysconfdir=/etc \
	    || error
    ) || error "configure"

    make $MAKEARGS || error

    install_sysroot_files || error

    install_fakeroot_init

    ln -sf /etc/gtk-2.0/gdk-pixbuf.loaders fakeroot/usr/lib/gdk-pixbuf-2.0/2.10.0/loaders.cache

    install_fakeroot_finish || error

    popd
    touch "$STATE_DIR/gdk_pixbuf.installed"
}

build_gdk_pixbuf
