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

LIBXML2=libxml2-2.7.2.tar.gz
LIBXML2_MIRROR=ftp://xmlsoft.org/libxml2
LIBXML2_DIR=$BUILD_DIR/libxml2-2.7.2
LIBXML2_ENV=

build_libxml2() {
    test -e "$STATE_DIR/libxml2-2.7.2" && return
    banner "Build $LIBXML2"
    download $LIBXML2_MIRROR $LIBXML2
    extract $LIBXML2
    apply_patches $LIBXML2_DIR $LIBXML2
    pushd $TOP_DIR
    cd $LIBXML2_DIR
    (
    CROSS_CFLAGS="-O2 $CROSS_CFLAGS"
    echo $CROSS_CONF_ENV
    eval \
	$CROSS_CONF_ENV \
	$LIBXML2_ENV \
	./configure --build=$BUILD_ARCH --host=$TARGET_ARCH \
	    --prefix=/usr \
	    --sysconfdir=/etc \
	    --with-c14n \
	    --with-catalog \
	    --without-debug \
	    --with-docbook \
	    --without-fexceptions \
	    --with-ftp \
	    --without-history \
	    --with-html \
	    --with-http \
	    --with-iso8859x \
	    --with-legacy \
	    --without-mem-debug \
	    --without-minimum \
	    --with-output \
	    --with-pattern \
	    --with-push \
	    --with-python=no \
	    --with-reader \
	    --with-regexps \
	    --without-run-debug \
	    --with-sax1  \
	    --with-schemas \
	    --with-schematron \
	    --with-threads \
	    --without-threads-alloc \
	    --with-tree \
	    --with-valid \
	    --with-writer \
	    --with-xinclude \
	    --with-xpath \
	    --with-xptr \
	    --with-modules \
	    --with-zlib=$TARGET_BIN_DIR \
	    || error
    )
    make $MAKEARGS || error

    install_sysroot_files || error
    
    ln -sf $TARGET_BIN_DIR/bin/xml2-config $HOST_BIN_DIR/bin/ || error
    
    $INSTALL -D -m 644 .libs/libxml2.so.2.7.2 $ROOTFS_DIR/usr/lib/libxml2.so.2.7.2 || error
    ln -sf libxml2.so.2.7.2 $ROOTFS_DIR/usr/lib/libxml2.so.2
    ln -sf libxml2.so.2.7.2 $ROOTFS_DIR/usr/lib/libxml2.so
    $STRIP $ROOTFS_DIR/usr/lib/libxml2.so.2.7.2

    popd
    touch "$STATE_DIR/libxml2-2.7.2"
}

build_libxml2
