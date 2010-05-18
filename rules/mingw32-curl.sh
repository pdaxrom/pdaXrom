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

MINGW32_CURL_VERSION=7.19.4
MINGW32_CURL=curl-${MINGW32_CURL_VERSION}.tar.bz2
MINGW32_CURL_MIRROR=http://curl.haxx.se/download
MINGW32_CURL_DIR=$BUILD_DIR/curl-${MINGW32_CURL_VERSION}
MINGW32_CURL_ENV="$CROSS_ENV_AC LIBS=-lz"

build_mingw32_curl() {
    test -e "$STATE_DIR/mingw32_curl.installed" && return
    banner "Build mingw32-curl"
    download $MINGW32_CURL_MIRROR $MINGW32_CURL
    extract $MINGW32_CURL
    apply_patches $MINGW32_CURL_DIR $MINGW32_CURL
    pushd $TOP_DIR
    cd $MINGW32_CURL_DIR

    local CROSSM=${TARGET_ARCH/-cygwin*}-mingw32-
    
    make mingw32-ssl-zlib \
	$MAKEARGS CC=${CROSSM}gcc RC=${CROSSM}windres AR=${CROSSM}ar RANLIB=${CROSSM}ranlib STRIP=${CROSSM}strip \
	DYN=1 \
	|| error

    $INSTALL -D -m 755 lib/libcurl.dll $TOOLCHAIN_PREFIX/${TARGET_ARCH/-cygwin*}-mingw32/bin/libcurl.dll || error
    $INSTALL -D -m 644 lib/libcurl.a $TOOLCHAIN_PREFIX/${TARGET_ARCH/-cygwin*}-mingw32/lib/libcurl.a || error
    $INSTALL -D -m 644 lib/libcurldll.a $TOOLCHAIN_PREFIX/${TARGET_ARCH/-cygwin*}-mingw32/lib/libcurldll.a || error

    for f in include/curl/*.h; do
	$INSTALL -D -m 644 $f $TOOLCHAIN_PREFIX/${TARGET_ARCH/-cygwin*}-mingw32/$f || error
    done

    popd
    touch "$STATE_DIR/mingw32_curl.installed"
}

build_mingw32_curl
