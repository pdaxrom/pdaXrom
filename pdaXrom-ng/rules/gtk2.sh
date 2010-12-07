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

GTK2_VERSION=2.23.2
GTK2=gtk+-${GTK2_VERSION}.tar.bz2
GTK2_MIRROR=http://ftp.acc.umu.se/pub/gnome/sources/gtk+/2.23
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

    install_fakeroot_init
    rm -rf fakeroot/usr/lib/gtk-2.0/include
    install_fakeroot_finish || error

    $INSTALL -D -m 755 $GENERICFS_DIR/etc/init.d/gtk $ROOTFS_DIR/etc/init.d/gtk || error

    if [ "$USE_FASTBOOT" = "yes" ]; then
	install_rc_start gtk 02
    else
	install_rc_start gtk 91
    fi

    popd
    touch "$STATE_DIR/gtk2.installed"
}

build_gtk2
