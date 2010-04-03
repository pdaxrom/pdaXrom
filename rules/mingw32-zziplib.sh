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

MINGW32_ZZIPLIB_VERSION=0.13.50
MINGW32_ZZIPLIB=zziplib-${MINGW32_ZZIPLIB_VERSION}.tar.bz2
MINGW32_ZZIPLIB_MIRROR=http://downloads.sourceforge.net/zziplib
MINGW32_ZZIPLIB_DIR=$BUILD_DIR/zziplib-${MINGW32_ZZIPLIB_VERSION}
MINGW32_ZZIPLIB_ENV="$CROSS_ENV_AC ac_cv_header_fnmatch_h=no"

build_mingw32_zziplib() {
    test -e "$STATE_DIR/mingw32_zziplib.installed" && return
    banner "Build mingw32-zziplib"
    download $MINGW32_ZZIPLIB_MIRROR $MINGW32_ZZIPLIB
    extract $MINGW32_ZZIPLIB
    apply_patches $MINGW32_ZZIPLIB_DIR $MINGW32_ZZIPLIB
    pushd $TOP_DIR
    mkdir -p $MINGW32_ZZIPLIB_DIR/build
    cd $MINGW32_ZZIPLIB_DIR/build
    (
    eval \
	$CROSS_CONF_ENV \
	$MINGW32_ZZIPLIB_ENV \
	../configure --build=$BUILD_ARCH --host=${TARGET_ARCH/-cygwin*}-mingw32 \
	    --prefix=$TOOLCHAIN_PREFIX/${TARGET_ARCH/-cygwin*}-mingw32 \
	    --disable-mmap \
	    --disable-shared \
	    --enable-static \
	    || error
    ) || error "configure"
    
    cd zzip
    
    make $MAKEARGS || error

    make install || error

    popd
    touch "$STATE_DIR/mingw32_zziplib.installed"
}

build_mingw32_zziplib
