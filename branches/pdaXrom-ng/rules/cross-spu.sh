build_binutils_spu() {
    test -e "$STATE_DIR/binutils-spu" && return
    banner "Build spu binutils $BINUTILS"
    echo "configure"
    pushd $TOP_DIR
    mkdir "$BINUTILS_DIR/build-spu"
    cd $BINUTILS_DIR/build-spu
    ../configure --target=spu --prefix=$TOOLCHAIN_PREFIX \
	--exec-prefix=$TOOLCHAIN_PREFIX --with-sysroot=$TOOLCHAIN_SYSROOT/usr/spu \
	--enable-werror=no --enable-64-bit-bfd --disable-debug \
	--disable-shared --program-prefix=spu- || error "configure"
    make $MAKEARGS MAKEINFO=true || error "make"
    make $MAKEARGS MAKEINFO=true install || error "make install"
    popd
    touch "$STATE_DIR/binutils-spu"
}

build_gcc_spu_bootstrap() {
    test -e "$STATE_DIR/gcc_bootstrap_spu" && return
    banner "Build gcc $GCC for configure newlib spu"
    echo "configure"
    pushd $TOP_DIR
    mkdir "$GCC_DIR/build_bootstr_spu"
    cd $GCC_DIR/build_bootstr_spu
    ../configure --target=spu --prefix=$TOOLCHAIN_PREFIX \
	--exec-prefix=$TOOLCHAIN_PREFIX --with-sysroot=$TOOLCHAIN_SYSROOT \
	--libexecdir=$TOOLCHAIN_PREFIX/lib \
	--program-prefix=spu- \
	--disable-checking \
	--without-headers \
	--with-newlib \
	--disable-libffi \
	--disable-threads \
	--disable-shared \
	--enable-languages=c \
	--disable-libgomp \
	--disable-libssp \
	--disable-libmudflap \
	--disable-multilib \
	--disable-nls \
	--disable-werror \
	--with-gnu-as \
	--with-gnu-ld \
	--with-system-zlib \
	--with-gmp=$HOST_BIN_DIR \
	--with-mpfr=$HOST_BIN_DIR \
	--disable-bootstrap || error "configure"
    make $MAKEARGS MAKEINFO=true || error "make"
    make MAKEINFO=true install || error "make install"
    popd

    ln -sf ${TARGET_ARCH}-gcc $TOOLCHAIN_PREFIX/bin/${TARGET_ARCH}-cc

    touch "$STATE_DIR/gcc_bootstrap_spu"
}

build_gcc_spu() {
    test -e "$STATE_DIR/gcc_spu" && return
    banner "Build gcc $GCC spu"
    echo "configure"
    pushd $TOP_DIR
    mkdir "$GCC_DIR/build_spu"
    cd $GCC_DIR/build_spu
    ../configure --target=spu --prefix=$TOOLCHAIN_PREFIX \
	--exec-prefix=$TOOLCHAIN_PREFIX --with-sysroot=$TOOLCHAIN_SYSROOT \
	--libexecdir=$TOOLCHAIN_PREFIX/lib \
	--program-prefix=spu- \
	--disable-checking \
	--with-headers \
	--with-newlib \
	--disable-libffi \
	--disable-threads \
	--disable-shared \
	--enable-languages=c,c++ \
	--disable-libgomp \
	--disable-libssp \
	--disable-libmudflap \
	--disable-multilib \
	--disable-nls \
	--disable-werror \
	--with-gnu-as \
	--with-gnu-ld \
	--with-system-zlib \
	--with-gmp=$HOST_BIN_DIR \
	--with-mpfr=$HOST_BIN_DIR \
	--disable-bootstrap || error "configure"
    make $MAKEARGS MAKEINFO=true || error "make"
    make MAKEINFO=true install || error "make install"
    popd

    ln -sf ${TARGET_ARCH}-gcc $TOOLCHAIN_PREFIX/bin/${TARGET_ARCH}-cc

    touch "$STATE_DIR/gcc_spu"
}

NEWLIB=newlib-1.17.0.tar.gz
NEWLIB_MIRROR=ftp://sources.redhat.com/pub/newlib
NEWLIB_DIR="$BUILD_DIR/newlib-1.17.0"

build_newlib_spu() {
    test -e "$STATE_DIR/newlib_spu" && return
    banner "Newlib"
    download $NEWLIB_MIRROR $NEWLIB
    extract $NEWLIB
    apply_patches $NEWLIB_DIR $NEWLIB
    pushd $TOP_DIR
    mkdir -p $NEWLIB_DIR/build
    cd $NEWLIB_DIR/build

    ../configure --prefix=$TOOLCHAIN_SYSROOT/usr \
	--with-sysroot=$TOOLCHAIN_SYSROOT \
	--disable-shared \
	--disable-threads \
	--disable-checking \
	--with-headers \
	--disable-multilib \
	--disable-nls \
	--with-system-zlib \
	--program-prefix=spu- \
	--target=spu \
	|| error

    make $MAKEARGS || error

    make $MAKEARGS install || error

    popd
    touch "$STATE_DIR/newlib_spu"
}

LIBSPE2=libspe2-2.2.80-132.tar.gz
LIBSPE2_MIRROR=http://www.bsc.es/projects/deepcomputing/linuxoncell/cellsimulator/sdk3.1/sources/libspe2
LIBSPE2_DIR="$BUILD_DIR/libspe2-2.2.80"

build_libspe2() {
    test -e "$STATE_DIR/libspe2" && return
    banner "Libspe2"
    download $LIBSPE2_MIRROR $LIBSPE2
    extract $LIBSPE2
    apply_patches $LIBSPE2_DIR $LIBSPE2
    pushd $TOP_DIR
    cd $LIBSPE2_DIR

    make ARCH=ppc CROSS_COMPILE=1 CROSS=${CROSS} || error

    make ARCH=ppc CROSS_COMPILE=1 CROSS=${CROSS} SYSROOT=$TOOLCHAIN_SYSROOT install || error

    for f in as cpp embedspu g++ gcc ld; do
	ln -sf ${TARGET_ARCH}-$f $TOOLCHAIN_PREFIX/bin/ppu32-$f || error
    done

    if [ -d $TOOLCHAIN_SYSROOT/usr/include/gnu ]; then
	test -e $TOOLCHAIN_SYSROOT/usr/include/gnu/stubs-64.h || ln -sf stubs-32.h $TOOLCHAIN_SYSROOT/usr/include/gnu/stubs-64.h
	test -e $TOOLCHAIN_SYSROOT/usr/include/gnu/stubs-32.h || ln -sf stubs-64.h $TOOLCHAIN_SYSROOT/usr/include/gnu/stubs-32.h
    fi

    popd
    touch "$STATE_DIR/libspe2"
}

build_binutils_spu

build_gcc_spu_bootstrap

build_newlib_spu

build_gcc_spu

build_libspe2
