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

CURL=curl-7.19.2.tar.bz2
CURL_MIRROR=http://curl.haxx.se/download
CURL_DIR=$BUILD_DIR/curl-7.19.2
CURL_ENV="$CROSS_ENV_AC"

build_curl() {
    test -e "$STATE_DIR/curl.installed" && return
    banner "Build curl"
    download $CURL_MIRROR $CURL
    extract $CURL
    apply_patches $CURL_DIR $CURL
    pushd $TOP_DIR
    cd $CURL_DIR
    (
    eval \
	$CROSS_CONF_ENV \
	$CURL_ENV \
	./configure --build=$BUILD_ARCH --host=$TARGET_ARCH \
	    --prefix=/usr \
	    --sysconfdir=/etc \
	    --with-random=/dev/urandom \
	    --with-zlib=$TARGET_BIN_DIR \
	    --with-gnutls=$TARGET_BIN_DIR \
	    --without-ssl \
	    --without-libssh2 \
	    --without-libidn \
	    --enable-crypto-auth \
	    || error
    ) || error "configure"
    
    make $MAKEARGS || error

    install_sysroot_files || error

    ln -sf $TARGET_BIN_DIR/bin/curl-config $HOST_BIN_DIR/bin/ || error
    
    $INSTALL -D -m 644 lib/.libs/libcurl.so.4.1.1 $ROOTFS_DIR/usr/lib/libcurl.so.4.1.1 || error
    ln -sf libcurl.so.4.1.1 $ROOTFS_DIR/usr/lib/libcurl.so.4
    ln -sf libcurl.so.4.1.1 $ROOTFS_DIR/usr/lib/libcurl.so
    $STRIP $ROOTFS_DIR/usr/lib/libcurl.so.4.1.1

    popd
    touch "$STATE_DIR/curl.installed"
}

build_curl
