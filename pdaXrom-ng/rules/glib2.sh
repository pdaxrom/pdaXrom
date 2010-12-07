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

GLIB2_VERSION=2.27.4
GLIB2=glib-${GLIB2_VERSION}.tar.bz2
GLIB2_MIRROR=http://ftp.gtk.org/pub/glib/2.27
GLIB2_DIR=$BUILD_DIR/glib-${GLIB2_VERSION}
GLIB2_ENV="$CROSS_ENV_AC glib_cv_uscore=no glib_cv_stack_grows=no"

build_glib2() {
    test -e "$STATE_DIR/glib2.installed" && return
    banner "Build glib2"
    download $GLIB2_MIRROR $GLIB2
    extract $GLIB2
    apply_patches $GLIB2_DIR $GLIB2
    pushd $TOP_DIR
    cd $GLIB2_DIR
    (
    eval \
	$CROSS_CONF_ENV \
	$GLIB2_ENV \
	./configure --build=$BUILD_ARCH --host=$TARGET_ARCH \
	    --prefix=/usr \
	    --sysconfdir=/etc \
	    || error
    ) || error

    make $MAKEARGS || error

    install_sysroot_files || error

    install_fakeroot_init
    rm -rf fakeroot/usr/lib/glib-2.0
    rm -rf fakeroot/usr/share/gdb fakeroot/usr/share/glib-2.0
    for f in glib-compile-schemas glib-genmarshal glib-gettextize glib-mkenums gobject-query gtester gtester-report; do
	rm -f fakeroot/usr/bin/$f
    done
    install_fakeroot_finish || error

    popd
    touch "$STATE_DIR/glib2.installed"
}

build_glib2
