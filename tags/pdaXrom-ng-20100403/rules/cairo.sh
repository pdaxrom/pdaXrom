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

CAIRO_VERSION=1.8.8
CAIRO=cairo-${CAIRO_VERSION}.tar.gz
CAIRO_MIRROR=http://cairographics.org/releases
CAIRO_DIR=$BUILD_DIR/cairo-${CAIRO_VERSION}
CAIRO_ENV="$CROSS_ENV_AC CFLAGS='-O4 -fomit-frame-pointer -ffast-math'"

build_cairo() {
    test -e "$STATE_DIR/cairo.installed" && return
    banner "Build cairo"
    download $CAIRO_MIRROR $CAIRO
    extract $CAIRO
    apply_patches $CAIRO_DIR $CAIRO
    pushd $TOP_DIR
    cd $CAIRO_DIR
    (
    eval \
	$CROSS_CONF_ENV \
	$CAIRO_ENV \
	./configure --build=$BUILD_ARCH --host=$TARGET_ARCH \
	    --prefix=/usr \
	    --sysconfdir=/etc \
	    --x-includes=$TARGET_INC \
	    --x-libraries=$TARGET_LIB \
	    --disable-quartz \
	    --disable-beos \
	    --disable-glitz \
	    --disable-atsui \
	    --enable-xcb \
	    --enable-svg \
	    --enable-ps \
	    --enable-pdf \
	    --enable-xlib \
	    --enable-ft \
	    --enable-png \
	    || error
    ) || error "configure"

    make $MAKEARGS || error

    install_sysroot_files || error

    install_fakeroot_init
    install_fakeroot_finish || error

    popd
    touch "$STATE_DIR/cairo.installed"
}

build_cairo
