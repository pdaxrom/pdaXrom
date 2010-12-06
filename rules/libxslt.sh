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

LIBXSLT=libxslt-1.1.24.tar.gz
LIBXSLT_MIRROR=ftp://xmlsoft.org/libxml2
LIBXSLT_DIR=$BUILD_DIR/libxslt-1.1.24
LIBXSLT_ENV="$CROSS_ENV_AC"

build_libxslt() {
    test -e "$STATE_DIR/libxslt.installed" && return
    banner "Build libxslt"
    download $LIBXSLT_MIRROR $LIBXSLT
    extract $LIBXSLT
    apply_patches $LIBXSLT_DIR $LIBXSLT
    pushd $TOP_DIR
    cd $LIBXSLT_DIR
    (
    eval \
	$CROSS_CONF_ENV \
	$LIBXSLT_ENV \
	./configure --build=$BUILD_ARCH --host=$TARGET_ARCH \
	    --prefix=/usr \
	    --sysconfdir=/etc \
	    --without-python \
	    --without-debug \
	    --without-mem-debug \
	    --without-crypto \
	    || error
    ) || error "configure"
    
    make $MAKEARGS || error

    install_sysroot_files || error

    ln -sf $TARGET_BIN_DIR/bin/xslt-config $HOST_BIN_DIR/bin/ || error
    
    $INSTALL -D -m 644 libxslt/.libs/libxslt.so.1.1.24 $ROOTFS_DIR/usr/lib/libxslt.so.1.1.24 || error
    ln -sf libxslt.so.1.1.24 $ROOTFS_DIR/usr/lib/libxslt.so.1
    ln -sf libxslt.so.1.1.24 $ROOTFS_DIR/usr/lib/libxslt.so
    $STRIP $ROOTFS_DIR/usr/lib/libxslt.so.1.1.24

    $INSTALL -D -m 644 libexslt/.libs/libexslt.so.0.8.13 $ROOTFS_DIR/usr/lib/libexslt.so.0.8.13 || error
    ln -sf libexslt.so.0.8.13 $ROOTFS_DIR/usr/lib/libexslt.so.0
    ln -sf libexslt.so.0.8.13 $ROOTFS_DIR/usr/lib/libexslt.so
    $STRIP $ROOTFS_DIR/usr/lib/libexslt.so.0.8.13

    popd
    touch "$STATE_DIR/libxslt.installed"
}

build_libxslt
