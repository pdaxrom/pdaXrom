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

OPENSSL_VERSION=0.9.8j
OPENSSL=openssl-${OPENSSL_VERSION}.tar.gz
OPENSSL_MIRROR=http://www.openssl.org/source
OPENSSL_DIR=$BUILD_DIR/openssl-${OPENSSL_VERSION}
OPENSSL_ENV=

build_openssl_thud() {
    case $1 in
    arm*l-*|armle-*)
	echo "linux-armel"
	;;
    arm*b-*|armbe-*)
	echo "linux-armeb"
	;;
    mips*l-*)
	echo "linux-mipsel"
	;;
    mips*-*)
	echo "linux-mipseb"
	;;
    ppc-*|powerpc-*)
	echo "linux-ppc"
	;;
    ppc64-*|powerpc64-*)
	echo "linux-ppc64"
	;;
    i586*-*)
	echo "linux-i386-i586"
	;;
    i386*-*|i486*-*)
	echo "linux-i386"
	;;
    i686*-*)
	echo "linux-i386-i686/cmov"
	;;
    x86_64-*|amd64-*)
	echo "linux-x86_64"
	;;
    *)
	error "Unknown arch"
	;;
    esac
}

build_openssl() {
    test -e "$STATE_DIR/openssl-${OPENSSL_VERSION}" && return
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
	./Configure threads \
		    shared \
		    zlib \
		    --prefix=/usr \
		    --openssldir=/etc/ssl \
		    -L$TARGET_LIB \
		    `build_openssl_thud $TARGET_ARCH` \
	    || error
    )

    case $TARGET_ARCH in
    *uclibc*)
	make INSTALLTOP=$TARGET_BIN_DIR openssl.pc libcrypto.pc libssl.pc CC=${TARGET_ARCH}-gcc \
	    RANLIB=${TARGET_ARCH}-ranlib AR="${TARGET_ARCH}-ar r" ARD="${TARGET_ARCH}-ar d" MAKEDEPPROG=${TARGET_ARCH}-gcc || error

	make CC=${TARGET_ARCH}-gcc RANLIB=${TARGET_ARCH}-ranlib AR="${TARGET_ARCH}-ar r" ARD="${TARGET_ARCH}-ar d" MAKEDEPPROG=${TARGET_ARCH}-gcc \
	    build_libs || error

	make CC=${TARGET_ARCH}-gcc RANLIB=${TARGET_ARCH}-ranlib AR="${TARGET_ARCH}-ar r" ARD="${TARGET_ARCH}-ar d" MAKEDEPPROG=${TARGET_ARCH}-gcc \
	     INSTALL_PREFIX=$TARGET_BIN_DIR INSTALLTOP='/usr' \
	     DIRS="crypto fips ssl engines" install_sw || error "install_sw"
	;;
    *)
	make INSTALLTOP=$TARGET_BIN_DIR openssl.pc CC=${TARGET_ARCH}-gcc \
	    RANLIB=${TARGET_ARCH}-ranlib AR="${TARGET_ARCH}-ar r" ARD="${TARGET_ARCH}-ar d" MAKEDEPPROG=${TARGET_ARCH}-gcc || error

	make CC=${TARGET_ARCH}-gcc RANLIB=${TARGET_ARCH}-ranlib AR="${TARGET_ARCH}-ar r" ARD="${TARGET_ARCH}-ar d" MAKEDEPPROG=${TARGET_ARCH}-gcc || error

	make CC=${TARGET_ARCH}-gcc RANLIB=${TARGET_ARCH}-ranlib AR="${TARGET_ARCH}-ar r" ARD="${TARGET_ARCH}-ar d" MAKEDEPPROG=${TARGET_ARCH}-gcc \
	    install INSTALL_PREFIX=$TARGET_BIN_DIR INSTALLTOP='/usr' || error
	;;
    esac

    $INSTALL -D -m 644 libcrypto.so.0.9.8 $ROOTFS_DIR/usr/lib/libcrypto.so.0.9.8 || error
    ln -sf libcrypto.so.0.9.8 $ROOTFS_DIR/usr/lib/libcrypto.so.0
    ln -sf libcrypto.so.0.9.8 $ROOTFS_DIR/usr/lib/libcrypto.so
    $STRIP $ROOTFS_DIR/usr/lib/libcrypto.so.0.9.8
    
    $INSTALL -D -m 644 libssl.so.0.9.8 $ROOTFS_DIR/usr/lib/libssl.so.0.9.8 || error
    ln -sf libssl.so.0.9.8 $ROOTFS_DIR/usr/lib/libssl.so.0
    ln -sf libssl.so.0.9.8 $ROOTFS_DIR/usr/lib/libssl.so
    $STRIP $ROOTFS_DIR/usr/lib/libssl.so.0.9.8

    popd
    touch "$STATE_DIR/openssl-${OPENSSL_VERSION}"
}

build_openssl
