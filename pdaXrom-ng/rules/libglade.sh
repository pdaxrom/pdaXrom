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

LIBGLADE_VERSION=2.6.4
LIBGLADE=libglade-${LIBGLADE_VERSION}.tar.bz2
LIBGLADE_MIRROR=http://ftp.gnome.org/pub/GNOME/sources/libglade/2.6
LIBGLADE_DIR=$BUILD_DIR/libglade-${LIBGLADE_VERSION}
LIBGLADE_ENV="$CROSS_ENV_AC"

build_libglade() {
    test -e "$STATE_DIR/libglade.installed" && return
    banner "Build libglade"
    download $LIBGLADE_MIRROR $LIBGLADE
    extract $LIBGLADE
    apply_patches $LIBGLADE_DIR $LIBGLADE
    pushd $TOP_DIR
    cd $LIBGLADE_DIR
    (
    eval \
	$CROSS_CONF_ENV \
	$LIBGLADE_ENV \
	./configure --build=$BUILD_ARCH --host=$TARGET_ARCH \
	    --prefix=/usr \
	    --sysconfdir=/etc \
	    || error
    ) || error "configure"

    make $MAKEARGS || error

    install_sysroot_files || error
    sed -i -e 's|moduledir=${libdir}|moduledir=/usr/lib|' ${TARGET_LIB}/pkgconfig/libglade-2.0.pc

    install_fakeroot_init
    rm -rf fakeroot/usr/bin
    rm -rf fakeroot/usr/share/xml
    install_fakeroot_finish || error

    popd
    touch "$STATE_DIR/libglade.installed"
}

build_libglade
