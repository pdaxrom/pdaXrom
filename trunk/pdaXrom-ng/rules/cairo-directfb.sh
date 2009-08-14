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

CAIRO=cairo-1.8.6.tar.gz
CAIRO_MIRROR=http://cairographics.org/releases
CAIRO_DIR=$BUILD_DIR/cairo-1.8.6
CAIRO_ENV="$CROSS_ENV_AC"

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
	    --disable-quartz \
	    --disable-beos \
	    --disable-glitz \
	    --disable-atsui \
	    --enable-directfb=yes \
	    --enable-xlib=no \
	    --enable-xlib-xrender=no \
	    --enable-xcb=no \
	    --without-x \
	    --disable-win32 \
	    --enable-png \
	    || error
    ) || error "configure"
    
    make $MAKEARGS || error

    install_sysroot_files || error

    $INSTALL -D -m 644 src/.libs/libcairo.so.2.10800.6 $ROOTFS_DIR/usr/lib/libcairo.so.2.10800.6 || error
    ln -sf libcairo.so.2.10800.6 $ROOTFS_DIR/usr/lib/libcairo.so.2
    ln -sf libcairo.so.2.10800.6 $ROOTFS_DIR/usr/lib/libcairo.so
    $STRIP $ROOTFS_DIR/usr/lib/libcairo.so.2.10800.6

    popd
    touch "$STATE_DIR/cairo.installed"
}

build_cairo
