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

MINGW32_LIBPNG=libpng-1.2.33.tar.bz2
MINGW32_LIBPNG_MIRROR=http://downloads.sourceforge.net/libpng
MINGW32_LIBPNG_DIR=$BUILD_DIR/libpng-1.2.33
MINGW32_LIBPNG_ENV="$CROSS_ENV_AC"

build_mingw32_libpng() {
    test -e "$STATE_DIR/mingw32_libpng.installed" && return
    banner "Build mingw32-libpng"
    download $MINGW32_LIBPNG_MIRROR $MINGW32_LIBPNG
    extract $MINGW32_LIBPNG
    apply_patches $MINGW32_LIBPNG_DIR $MINGW32_LIBPNG
    pushd $TOP_DIR
    cd $MINGW32_LIBPNG_DIR
    (
    eval \
	$CROSS_CONF_ENV \
	$MINGW32_LIBPNG_ENV \
	./configure --build=$BUILD_ARCH --host=${TARGET_ARCH/-cygwin*}-mingw32 \
	    --prefix=$TOOLCHAIN_PREFIX/${TARGET_ARCH/-cygwin*}-mingw32 \
	    || error
    ) || error "configure"
    
    make $MAKEARGS || error

    make install || error

    popd
    touch "$STATE_DIR/mingw32_libpng.installed"
}

build_mingw32_libpng
