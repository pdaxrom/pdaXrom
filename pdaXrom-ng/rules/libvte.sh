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

LIBVTE_VERSION=0.27.2
LIBVTE=vte-${LIBVTE_VERSION}.tar.bz2
LIBVTE_MIRROR=http://ftp.gnome.org/pub/GNOME/sources/vte/0.27
LIBVTE_DIR=$BUILD_DIR/vte-${LIBVTE_VERSION}
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
	    --libexecdir=/usr/lib/vte \
	    --disable-glade \
	    --disable-gtk-doc \
	    --disable-python \
	    || error
    ) || error "configure"

    make $MAKEARGS || error

    install_sysroot_files || error

    install_fakeroot_init

    install_fakeroot_finish || error

    #$INSTALL -D -m 644 termcaps/xterm.baseline $ROOTFS_DIR/etc/termcap || error

    popd
    touch "$STATE_DIR/libvte.installed"
}

build_libvte
