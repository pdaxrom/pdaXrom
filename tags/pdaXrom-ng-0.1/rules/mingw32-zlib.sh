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

MINGW32_ZLIB=zlib-1.2.3-ptx4.tar.bz2
MINGW32_ZLIB_MIRROR=http://www.pengutronix.de/software/ptxdist/temporary-src
MINGW32_ZLIB_DIR=$BUILD_DIR/zlib-1.2.3-ptx4
MINGW32_ZLIB_ENV="$CROSS_ENV_AC"

build_mingw32_zlib() {
    test -e "$STATE_DIR/mingw32_zlib.installed" && return
    banner "Build mingw32-zlib"
    download $MINGW32_ZLIB_MIRROR $MINGW32_ZLIB
    extract $MINGW32_ZLIB
    apply_patches $MINGW32_ZLIB_DIR $MINGW32_ZLIB
    pushd $TOP_DIR
    cd $MINGW32_ZLIB_DIR
    (
    eval \
	$CROSS_CONF_ENV \
	$MINGW32_ZLIB_ENV \
	./configure --build=$BUILD_ARCH --host=${TARGET_ARCH/-cygwin*}-mingw32 \
	    --prefix=$TOOLCHAIN_PREFIX/${TARGET_ARCH/-cygwin*}-mingw32 \
	    || error
    ) || error "configure"
    
    make $MAKEARGS || error

    make install || error

    popd
    touch "$STATE_DIR/mingw32_zlib.installed"
}

build_mingw32_zlib
