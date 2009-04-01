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
	    --x-includes=$TARGET_INC \
	    --x-libraries=$TARGET_LIB \
	    || error
    ) || error "configure"
    
    make $MAKEARGS || error

    install_sysroot_files || error

    for f in pango pangocairo pangoft2 pangox pangoxft; do
	$INSTALL -D -m 644 pango/.libs/lib${f}-1.0.so.0.2400.0 $ROOTFS_DIR/usr/lib/lib${f}-1.0.so.0.2400.0 || error
	ln -sf lib${f}-1.0.so.0.2400.0 $ROOTFS_DIR/usr/lib/lib${f}-1.0.so.0
	ln -sf lib${f}-1.0.so.0.2400.0 $ROOTFS_DIR/usr/lib/lib${f}-1.0.so
	$STRIP $ROOTFS_DIR/usr/lib/lib${f}-1.0.so.0.2400.0
    done

    $INSTALL -D -m 755 pango/.libs/pango-querymodules $ROOTFS_DIR/usr/bin/pango-querymodules || error
    $STRIP $ROOTFS_DIR/usr/bin/pango-querymodules

    mkdir -p $ROOTFS_DIR/usr/lib/pango/1.6.0/modules || error "mkdir"
    find modules/ -name "*.so" | while read f; do
	$INSTALL -D -m 644 $f $ROOTFS_DIR/usr/lib/pango/1.6.0/modules/${f/*\/} || error "install $f"
	$STRIP $ROOTFS_DIR/usr/lib/pango/1.6.0/modules/${f/*\/} || error "strip ${f/*\/}"
    done

    $INSTALL -D -m 644 pango/pangox.aliases $ROOTFS_DIR/etc/pango/pangox.aliases || error
    $INSTALL -D -m 755 $GENERICFS_DIR/etc/init.d/pango $ROOTFS_DIR/etc/init.d/pango || error
    install_rc_start pango 90

    popd
    touch "$STATE_DIR/pango.installed"
}

build_pango
