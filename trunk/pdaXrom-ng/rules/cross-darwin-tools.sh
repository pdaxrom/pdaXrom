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

DARWINSDK_DIR=darwin10-sdk-0.2
DARWINSDK=${DARWINSDK_DIR}.tar.gz
DARWINSDK_MIRROR=http://mail.pdaxrom.org/downloads/src

install_sysroot() {
    test -e "$STATE_DIR/sysroot.installed" && return
    banner "Install sysroot"
    download $DARWINSDK_MIRROR $DARWINSDK

    local SDK=`dirname ${TOOLCHAIN_SYSROOT}`
    tar zfx ${SRC_DIR}/${DARWINSDK} -C ${SDK} || error "unpack sysroot"
    mv -f ${SDK}/${DARWINSDK_DIR} ${TOOLCHAIN_SYSROOT}

    touch "$STATE_DIR/sysroot.installed"
}

install_sysroot

ODCCTOOLS_VERSION=758-20091206
ODCCTOOLS=odcctools-${ODCCTOOLS_VERSION}.tar.bz2
ODCCTOOLS_MIRROR=http://mail.pdaxrom.org/downloads/src
ODCCTOOLS_DIR=$BUILD_DIR/odcctools-${ODCCTOOLS_VERSION}
ODCCTOOLS_ENV="$CROSS_ENV_AC"

case "$BUILD_ARCH" in
x86_64-*|amd64-*|ppc64-*|mips64*)
    ODCCTOOLS_ENV="$ODCCTOOLS_ENV CXXFLAGS='-O2 -m32' CFLAGS='-O2 -m32' LDFLAGS='-m32'"
    ;;
esac

build_odcctools() {
    test -e "$STATE_DIR/odcctools.installed" && return
    banner "Build odcctools"
    download $ODCCTOOLS_MIRROR $ODCCTOOLS
    extract $ODCCTOOLS
    apply_patches $ODCCTOOLS_DIR $ODCCTOOLS
    pushd $TOP_DIR
    cd $ODCCTOOLS_DIR
    (
    eval \
	$CROSS_CONF_ENV \
	$ODCCTOOLS_ENV \
	./configure --target=$TARGET_ARCH \
	    --prefix=$TOOLCHAIN_PREFIX \
	    --with-sysroot=$TOOLCHAIN_SYSROOT \
	    || error
    ) || error "configure"

    make $MAKEARGS || error

    make $MAKEARGS install || error

    popd
    touch "$STATE_DIR/odcctools.installed"
}

build_odcctools

GCC_VERSION=5646
GCC="gcc-${GCC_VERSION}.tar.gz"
GCC_MIRROR="www.opensource.apple.com/darwinsource/tarballs/other"
GCC_DIR="$BUILD_DIR/gcc-${GCC_VERSION}"
GCC_ENV=""

#case "$BUILD_ARCH" in
#x86_64-*|amd64-*|ppc64-*|mips64*)
#    GCC_ENV="$GCC_ENV CXXFLAGS='-O2 -m32' CFLAGS='-O2 -m32' LDFLAGS='-m32'"
#    ;;
#esac

build_gcc() {
    test -e "$STATE_DIR/gcc" && return
    banner "Build gcc $GCC"
    download $GCC_MIRROR $GCC
    extract $GCC
    apply_patches $GCC_DIR $GCC
    local CONF_ARGS=""
    pushd $TOP_DIR
    mkdir "$GCC_DIR/build"
    cd $GCC_DIR
    sed -i -e "s|/usr/bin/libtool|${TOOLCHAIN_PREFIX}/bin/${CROSS}libtool|" gcc/config/darwin.h
    sed -i -e "s|shell lipo -info /usr/lib/libSystem.B.dylib|shell ${TOOLCHAIN_PREFIX}/bin/${CROSS}lipo -info ${TOOLCHAIN_SYSROOT}/usr/lib/libSystem.B.dylib|" gcc/config/i386/t-darwin
    sed -i -e "s|= lipo|= ${CROSS}lipo|" gcc/Makefile.in
    sed -i -e "s|= strip|= ${CROSS}strip|" gcc/Makefile.in
    cd $GCC_DIR/build

    eval \
    $GCC_ENV \
    ../configure --target=$TARGET_ARCH --prefix=$TOOLCHAIN_PREFIX \
	--exec-prefix=$TOOLCHAIN_PREFIX --with-sysroot=$TOOLCHAIN_SYSROOT \
	--disable-checking \
	--enable-languages=c,c++ \
	--with-as=${TOOLCHAIN_PREFIX}/bin/${CROSS}as \
	--with-ld=${TOOLCHAIN_PREFIX}/bin/${CROSS}ld \
	--with-nm=${TOOLCHAIN_PREFIX}/bin/${CROSS}nm \
	--with-lipo=${TOOLCHAIN_PREFIX}/bin/${CROSS}lipo \
	--with-strip=${TOOLCHAIN_PREFIX}/bin/${CROSS}strip \
	--disable-libgomp \
	--disable-libssp \
	--disable-libmudflap \
	$CONF_ARGS \
	|| error "configure"

    make $MAKEARGS MAKEINFO=true STRIP_FOR_TARGET=${CROSS}strip LIPO_FOR_TARGET=${CROSS}lipo || error "build"
    make MAKEINFO=true install || error "make install"
    popd

    ln -sf ${TARGET_ARCH}-gcc $TOOLCHAIN_PREFIX/bin/${TARGET_ARCH}-cc

    touch "$STATE_DIR/gcc"
}

build_gcc
