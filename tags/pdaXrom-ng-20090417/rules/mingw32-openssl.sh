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

build_openssl() {
    test -e "$STATE_DIR/mingw32-openssl-${OPENSSL_VERSION}" && return
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
	./Configure zlib \
		    --prefix=${TOOLCHAIN_PREFIX}/${TARGET_ARCH/-*}-mingw32 \
		    mingw-cross \
	    || error
    )
    
    make || error
    
    make install || error

    popd
    touch "$STATE_DIR/mingw32-openssl-${OPENSSL_VERSION}"
}

build_openssl
