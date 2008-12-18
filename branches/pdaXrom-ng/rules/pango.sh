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

PANGO=pango-1.22.4.tar.bz2
PANGO_MIRROR=http://ftp.gnome.org/pub/GNOME/sources/pango/1.22
PANGO_DIR=$BUILD_DIR/pango-1.22.4
PANGO_ENV="$CROSS_ENV_AC"
PANGO_MODULES="basic-fc,basic-win32,basic-x,basic-atsui"

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
	./configure --host=$TARGET_ARCH \
	    --prefix=/usr \
	    --sysconfdir=/etc \
	    --enable-explicit-deps=yes \
	    --without-dynamic-modules \
	    --with-included-modules="$PANGO_MODULES" \
	    --x-includes=$TARGET_INC \
	    --x-libraries=$TARGET_LIB \
	    || error
    ) || error "configure"
    
    make $MAKEARGS || error

    install_sysroot_files || error
    
    for f in pango pangocairo pangoft2 pangox pangoxft; do
	$INSTALL -D -m 644 pango/.libs/lib${f}-1.0.so.0.2203.1 $ROOTFS_DIR/usr/lib/lib${f}-1.0.so.0.2203.1 || error
	ln -sf lib${f}-1.0.so.0.2203.1 $ROOTFS_DIR/usr/lib/lib${f}-1.0.so.0
	ln -sf lib${f}-1.0.so.0.2203.1 $ROOTFS_DIR/usr/lib/lib${f}-1.0.so
	$STRIP $ROOTFS_DIR/usr/lib/lib${f}-1.0.so.0.2203.1
    done

    popd
    touch "$STATE_DIR/pango.installed"
}

build_pango
