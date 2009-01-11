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

OPENSSL=openssl-0.9.8j.tar.gz
OPENSSL_MIRROR=http://www.openssl.org/source
OPENSSL_DIR=$BUILD_DIR/openssl-0.9.8j
OPENSSL_ENV=

build_openssl_thud() {
    case $1 in
    arm*|xscale*)
	echo "linux-arm"
	;;
    ppc*|powerpc*)
	echo "linux-ppc"
	;;
    i586*)
	echo "linux-i386-i586"
	;;
    i386*|i486*)
	echo "linux-i386"
	;;
    i686*)
	echo "linux-i386-i686/cmov"
	;;
    *)
	error "Unknown arch"
	;;
    esac
}

build_openssl() {
    test -e "$STATE_DIR/openssl-0.9.8i" && return
    banner "Build $OPENSSL"
    download $OPENSSL_MIRROR $OPENSSL
    extract $OPENSSL
    apply_patches $OPENSSL_DIR $OPENSSL
    pushd $TOP_DIR
    cd $OPENSSL_DIR
    (
    eval \
	$CROSS_CONF_ENV \
	$OPENSSL_ENV \
	./Configure `build_openssl_thud $TARGET_ARCH` \
	    --openssldir=/etc/ssl \
	    shared \
	    || error
    )
    
    make INSTALLTOP=$TARGET_BIN_DIR openssl.pc CC=${TARGET_ARCH}-gcc RANLIB=${TARGET_ARCH}-ranlib AR='${TARGET_ARCH}-ar r' || error

    make CC=${TARGET_ARCH}-gcc RANLIB=${TARGET_ARCH}-ranlib AR='${TARGET_ARCH}-ar r' || error

    make CC=${TARGET_ARCH}-gcc RANLIB=${TARGET_ARCH}-ranlib AR='${TARGET_ARCH}-ar r' \
	install INSTALL_PREFIX=$TARGET_BIN_DIR INSTALLTOP='/usr' \
	|| error

    $INSTALL -D -m 644 libcrypto.so.0.9.8 $ROOTFS_DIR/usr/lib/libcrypto.so.0.9.8 || error
    ln -sf libcrypto.so.0.9.8 $ROOTFS_DIR/usr/lib/libcrypto.so.0
    ln -sf libcrypto.so.0.9.8 $ROOTFS_DIR/usr/lib/libcrypto.so
    $STRIP $ROOTFS_DIR/usr/lib/libcrypto.so.0.9.8
    
    $INSTALL -D -m 644 libssl.so.0.9.8 $ROOTFS_DIR/usr/lib/libssl.so.0.9.8 || error
    ln -sf libssl.so.0.9.8 $ROOTFS_DIR/usr/lib/libssl.so.0
    ln -sf libssl.so.0.9.8 $ROOTFS_DIR/usr/lib/libssl.so
    $STRIP $ROOTFS_DIR/usr/lib/libssl.so.0.9.8

    popd
    touch "$STATE_DIR/openssl-0.9.8i"
}

build_openssl
