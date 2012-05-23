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

HOST_E2FSPROGS32_VERSION=1.41.9
HOST_E2FSPROGS32=e2fsprogs-${HOST_E2FSPROGS32_VERSION}.tar.gz
HOST_E2FSPROGS32_MIRROR=http://prdownloads.sourceforge.net/e2fsprogs
HOST_E2FSPROGS32_DIR=$HOST_BUILD_DIR/e2fsprogs-${HOST_E2FSPROGS32_VERSION}
HOST_E2FSPROGS32_ENV=

case "$BUILD_ARCH" in
x86_64-*|amd64-*|ppc64-*|mips64*)
    HOST_E2FSPROGS32_ENV="CFLAGS='-O2 -m32' CXXFLAGS='-O2 -m32' LDFLAGS='-m32'"
    ;;
esac

build_host_e2fsprogs32() {
    test -e "$STATE_DIR/host_e2fsprogs32.installed" && return
    banner "Build host-e2fsprogs32"
    download $HOST_E2FSPROGS32_MIRROR $HOST_E2FSPROGS32
    extract_host $HOST_E2FSPROGS32
    apply_patches $HOST_E2FSPROGS32_DIR $HOST_E2FSPROGS32
    pushd $TOP_DIR
    cd $HOST_E2FSPROGS32_DIR
    (
    eval $HOST_E2FSPROGS32_ENV \
	./configure --prefix=${HOST_BIN_DIR}/32 \
    ) || error
    make -C lib/uuid $MAKEARGS || error
    make -C lib/uuid $MAKEARGS install || error
    test -e ${HOST_BIN_DIR}/lib32 || ln -s 32/lib ${HOST_BIN_DIR}/lib32
    popd
    touch "$STATE_DIR/host_e2fsprogs32.installed"
}

build_host_e2fsprogs32

OPENSSL32_VERSION=0.9.8j
OPENSSL32=openssl-${OPENSSL32_VERSION}.tar.gz
OPENSSL32_MIRROR=http://www.openssl.org/source
OPENSSL32_DIR=$BUILD_DIR/openssl-${OPENSSL32_VERSION}
#OPENSSL32_ENV="CFLAGS='-O3 -fomit-frame-pointer -m32' LDFLAGS='-m32'"

build_openssl32() {
    test -e "$STATE_DIR/openssl32-${OPENSSL32_VERSION}" && return
    banner "Build $OPENSSL32"
    download $OPENSSL32_MIRROR $OPENSSL32
    extract $OPENSSL32
    apply_patches $OPENSSL32_DIR $OPENSSL32
    pushd $TOP_DIR
    cd $OPENSSL32_DIR
    (
    eval \
	$CROSS_CONF_ENV \
	$OPENSSL32_ENV \
	./Configure \
		    --prefix=${HOST_BIN_DIR}/32 \
		    linux-generic32:gcc:"-DTERMIO -O3 -fomit-frame-pointer -Wall -m32" \
	    || error
    )
    
    make || error
    
    make install || error

    test -e ${HOST_BIN_DIR}/lib32 || ln -s 32/lib ${HOST_BIN_DIR}/lib32

    popd
    touch "$STATE_DIR/openssl32-${OPENSSL32_VERSION}"
}

build_openssl32

ODCCTOOLS_VERSION=758-20091206
ODCCTOOLS=odcctools-${ODCCTOOLS_VERSION}.tar.bz2
ODCCTOOLS_MIRROR=http://mail.pdaxrom.org/downloads/src
ODCCTOOLS_DIR=$BUILD_DIR/odcctools-${ODCCTOOLS_VERSION}
ODCCTOOLS_ENV="$CROSS_ENV_AC"

case "$BUILD_ARCH" in
x86_64-*|amd64-*|ppc64-*|mips64*)
    ODCCTOOLS_ENV="$ODCCTOOLS_ENV \
	CXXFLAGS='-m32 -I${HOST_BIN_DIR}/32/include' \
	CFLAGS='-m32 -I${HOST_BIN_DIR}/32/include' \
	LDFLAGS='-m32 -L${HOST_BIN_DIR}/32/lib'"
    ;;
*)
    ODCCTOOLS_ENV="$ODCCTOOLS_ENV \
	CXXFLAGS='-I${HOST_BIN_DIR}/32/include' \
	CFLAGS='-I${HOST_BIN_DIR}/32/include' \
	LDFLAGS='-L${HOST_BIN_DIR}/32/lib'"
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
    sed -i -e 's|CFLAGS -Wno-long-double|CFLAGS|' configure
    sed -i -e 's|WARNINGS -Wno-long-double|WARNINGS|' configure
    sed -i -e 's|-lssl|"-lcrypto -ldl"|' configure
    (
    eval \
	$CROSS_CONF_ENV \
	$ODCCTOOLS_ENV \
	./configure --target=$TARGET_ARCH \
	    --prefix=$TOOLCHAIN_PREFIX \
	    --libexecdir=$TOOLCHAIN_PREFIX/lib \
	    --with-sysroot=$TOOLCHAIN_SYSROOT \
	    || error
    ) || error "configure"

    sed -i -e "s|ld64||" Makefile

    make $MAKEARGS || error

    make $MAKEARGS install || error

    popd
    touch "$STATE_DIR/odcctools.installed"
}

build_odcctools

ODCCTOOLSLD_VERSION=9.2
ODCCTOOLSLD=odcctools-${ODCCTOOLSLD_VERSION}-ld.tar.bz2
ODCCTOOLSLD_MIRROR=http://mail.pdaxrom.org/downloads/src
ODCCTOOLSLD_DIR=$BUILD_DIR/odcctools-${ODCCTOOLSLD_VERSION}-ld
ODCCTOOLSLD_ENV="$CROSS_ENV_AC"
build_odcctools_ld() {
    test -e "$STATE_DIR/odcctools_ld.installed" && return
    banner "Build odcctools_ld"
    download $ODCCTOOLSLD_MIRROR $ODCCTOOLSLD
    extract $ODCCTOOLSLD
    apply_patches $ODCCTOOLSLD_DIR $ODCCTOOLSLD
    pushd $TOP_DIR
    cd $ODCCTOOLSLD_DIR

    CFLAGS="-m32" LDFLAGS="-m32" ./configure \
	    --target=$TARGET_ARCH \
	    --prefix=$TOOLCHAIN_PREFIX \
	    --libexecdir=$TOOLCHAIN_PREFIX/lib \
	    --with-sysroot=$TOOLCHAIN_SYSROOT \
	     --enable-ld64 || error "configure"
    cd libstuff
    make || error "make"
    cd ../ld64
    make || error "make"
    make install || error "install"
    ln -sf ${TARGET_ARCH}-ld64 ${TOOLCHAIN_PREFIX}/bin/${TARGET_ARCH}-ld

    popd
    touch "$STATE_DIR/odcctools_ld.installed"
}

build_odcctools_ld














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
	--libexecdir=$TOOLCHAIN_PREFIX/lib \
	--with-gxx-include-dir=${TOOLCHAIN_SYSROOT}/usr/include/c++/4.2.1 \
	--disable-checking \
	--enable-languages=c,objc,c++,obj-c++ \
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
