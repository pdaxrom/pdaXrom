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

LIBTASN1=libtasn1-1.7.tar.gz
LIBTASN1_MIRROR=http://ftp.gnu.org/pub/gnu/gnutls
LIBTASN1_DIR=$BUILD_DIR/libtasn1-1.7
LIBTASN1_ENV="$CROSS_ENV_AC"

build_libtasn1() {
    test -e "$STATE_DIR/libtasn1.installed" && return
    banner "Build libtasn1"
    download $LIBTASN1_MIRROR $LIBTASN1
    extract $LIBTASN1
    apply_patches $LIBTASN1_DIR $LIBTASN1
    pushd $TOP_DIR
    cd $LIBTASN1_DIR
    (
    eval \
	$CROSS_CONF_ENV \
	$LIBTASN1_ENV \
	./configure --build=$BUILD_ARCH --host=$TARGET_ARCH \
	    --prefix=/usr \
	    --sysconfdir=/etc \
	    || error
    ) || error "configure"
    
    make $MAKEARGS || error

    install_sysroot_files || error

    ln -sf $TARGET_BIN_DIR/bin/libtasn1-config $HOST_BIN_DIR/bin/
    
    $INSTALL -D -m 644 lib/.libs/libtasn1.so.3.1.1 $ROOTFS_DIR/usr/lib/libtasn1.so.3.1.1 || error
    ln -sf libtasn1.so.3.1.1 $ROOTFS_DIR/usr/lib/libtasn1.so.3
    ln -sf libtasn1.so.3.1.1 $ROOTFS_DIR/usr/lib/libtasn1.so
    $STRIP $ROOTFS_DIR/usr/lib/libtasn1.so.3.1.1

    popd
    touch "$STATE_DIR/libtasn1.installed"
}

build_libtasn1
