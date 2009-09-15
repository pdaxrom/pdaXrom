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

MINGW32_LIBJPEG=libjpeg-6b-ptx1.tar.bz2
MINGW32_LIBJPEG_MIRROR=http://www.pengutronix.de/software/ptxdist/temporary-src
MINGW32_LIBJPEG_DIR=$BUILD_DIR/libjpeg-6b-ptx1
MINGW32_LIBJPEG_ENV="$CROSS_ENV_AC"

build_mingw32_libjpeg() {
    test -e "$STATE_DIR/mingw32_libjpeg.installed" && return
    banner "Build mingw32-libjpeg"
    download $MINGW32_LIBJPEG_MIRROR $MINGW32_LIBJPEG
    extract $MINGW32_LIBJPEG
    apply_patches $MINGW32_LIBJPEG_DIR $MINGW32_LIBJPEG
    pushd $TOP_DIR
    cd $MINGW32_LIBJPEG_DIR
    (
    eval \
	$CROSS_CONF_ENV \
	$MINGW32_LIBJPEG_ENV \
	./configure --build=$BUILD_ARCH --host=${TARGET_ARCH/-cygwin*}-mingw32 \
	    --prefix=$TOOLCHAIN_PREFIX/${TARGET_ARCH/-cygwin*}-mingw32 \
	    || error
    ) || error "configure"
    
    make $MAKEARGS || error

    make install || error
    
    popd
    touch "$STATE_DIR/mingw32_libjpeg.installed"
}

build_mingw32_libjpeg
