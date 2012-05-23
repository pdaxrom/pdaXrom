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

MINGW32_FLTK_2_0_X_VERSION=r6970
MINGW32_FLTK_2_0_X=fltk-2.0.x-${MINGW32_FLTK_2_0_X_VERSION}.tar.bz2
MINGW32_FLTK_2_0_X_MIRROR=http://ftp.rz.tu-bs.de/pub/mirror/ftp.easysw.com/ftp/pub/fltk/snapshots
MINGW32_FLTK_2_0_X_DIR=$BUILD_DIR/fltk-2.0.x-${MINGW32_FLTK_2_0_X_VERSION}
MINGW32_FLTK_2_0_X_ENV="$CROSS_ENV_AC"

build_mingw32_fltk_2_0_x() {
    test -e "$STATE_DIR/mingw32_fltk_2_0_x.installed" && return
    banner "Build mingw32-fltk-2_0_x"
    download $MINGW32_FLTK_2_0_X_MIRROR $MINGW32_FLTK_2_0_X
    extract $MINGW32_FLTK_2_0_X
    apply_patches $MINGW32_FLTK_2_0_X_DIR $MINGW32_FLTK_2_0_X
    pushd $TOP_DIR
    cd $MINGW32_FLTK_2_0_X_DIR
    sed -i 's|uname=`uname`|uname=MINGW32|g' configure
    (
    eval \
	$CROSS_CONF_ENV \
	$MINGW32_FLTK_2_0_X_ENV \
	./configure --build=$BUILD_ARCH --host=${TARGET_ARCH/-*}-mingw32 \
		    --prefix=${TOOLCHAIN_PREFIX}/${TARGET_ARCH/-*}-mingw32 \
	    || error
    ) || error "configure"
    
    make $MAKEARGS || error

    make $MAKEARGS STRIP=true install || error

    ln -sf ../${TARGET_ARCH/-*}-mingw32/bin/fltk2-config ${TOOLCHAIN_PREFIX}/bin/fltk2-config

    popd
    touch "$STATE_DIR/mingw32_fltk_2_0_x.installed"
}

build_mingw32_fltk_2_0_x
