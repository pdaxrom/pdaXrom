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

PANGO_VERSION=1.24.0
PANGO=pango-${PANGO_VERSION}.tar.bz2
PANGO_MIRROR=http://ftp.gnome.org/pub/GNOME/sources/pango/1.24
PANGO_DIR=$BUILD_DIR/pango-${PANGO_VERSION}
PANGO_ENV="$CROSS_ENV_AC"
PANGO_MODULES="basic-x,basic-fc"

build_pango() {
    test -e "$STATE_DIR/pango.installed" && return
    banner "Build pango"
    download $PANGO_MIRROR $PANGO
    extract $PANGO
    apply_patches $PANGO_DIR $PANGO
    pushd $TOP_DIR
    cd $PANGO_DIR
    (
    eval \
	$CROSS_CONF_ENV \
	$PANGO_ENV \
	./configure --build=$BUILD_ARCH --host=$TARGET_ARCH \
	    --prefix=/usr \
	    --sysconfdir=/etc \
	    --with-included-modules="$PANGO_MODULES" \
	    --enable-explicit-deps=yes \
	    --enable-cairo \
	    --without-x \
	    --disable-xlib \
	    --disable-win32 \
	    || error
    ) || error "configure"
    
    make $MAKEARGS || error

    install_sysroot_files || error

    install_fakeroot_init
    install_fakeroot_finish || error

    $INSTALL -D -m 755 $GENERICFS_DIR/etc/init.d/pango $ROOTFS_DIR/etc/init.d/pango || error
    if [ "$USE_FASTBOOT" = "yes" ]; then
	install_rc_start pango 01
    else
	install_rc_start pango 90
    fi

    popd
    touch "$STATE_DIR/pango.installed"
}

build_pango
