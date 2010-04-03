#
# packet template
#
# Copyright (C) 2009 by Alexander Chukov <sash@pdaXrom.org>
#          
# See CREDITS for details about who has contributed to this project.
#
# For further information about the pdaXrom project and license conditions
# see the README file.
#

POPPLER_VERSION=0.10.4
POPPLER=poppler-${POPPLER_VERSION}.tar.gz
POPPLER_MIRROR=http://poppler.freedesktop.org
POPPLER_DIR=$BUILD_DIR/poppler-${POPPLER_VERSION}
POPPLER_ENV="$CROSS_ENV_AC"

build_poppler() {
    test -e "$STATE_DIR/poppler.installed" && return
    banner "Build poppler"
    download $POPPLER_MIRROR $POPPLER
    extract $POPPLER
    apply_patches $POPPLER_DIR $POPPLER
    pushd $TOP_DIR
    cd $POPPLER_DIR
    (
    eval \
	$CROSS_CONF_ENV \
	$POPPLER_ENV \
	./configure --build=$BUILD_ARCH --host=$TARGET_ARCH \
	    --prefix=/usr \
	    --sysconfdir=/etc \
	    --disable-poppler-qt \
	    --disable-poppler-qt4 \
	    --enable-zlib \
	    || error
    ) || error "configure"
    
    make $MAKEARGS || error

    install_sysroot_files || error
    
    $INSTALL -D -m 644 glib/.libs/libpoppler-glib.so.4.0.0 $ROOTFS_DIR/usr/lib/libpoppler-glib.so.4.0.0 || error
    ln -sf libpoppler-glib.so.4.0.0 $ROOTFS_DIR/usr/lib/libpoppler-glib.so.4
    ln -sf libpoppler-glib.so.4.0.0 $ROOTFS_DIR/usr/lib/libpoppler-glib.so
    $STRIP $ROOTFS_DIR/usr/lib/libpoppler-glib.so.4.0.0
    
    $INSTALL -D -m 644 poppler/.libs/libpoppler.so.4.0.0 $ROOTFS_DIR/usr/lib/libpoppler.so.4.0.0 || error
    ln -sf libpoppler.so.4.0.0 $ROOTFS_DIR/usr/lib/libpoppler.so.4
    ln -sf libpoppler.so.4.0.0 $ROOTFS_DIR/usr/lib/libpoppler.so
    $STRIP $ROOTFS_DIR/usr/lib/libpoppler.so.4.0.0

    for f in pdffonts pdfimages pdfinfo pdftoabw pdftohtml pdftoppm pdftops pdftotext; do
	$INSTALL -D -m 755 utils/.libs/$f $ROOTFS_DIR/usr/bin/$f || error
	$STRIP $ROOTFS_DIR/usr/bin/$f
    done

    popd
    touch "$STATE_DIR/poppler.installed"
}

build_poppler
