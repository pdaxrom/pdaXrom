build_target_binutils_spu() {
    test -e "$STATE_DIR/target-binutils-spu" && return
    banner "Build spu binutils $BINUTILS"
    echo "configure"
    pushd $TOP_DIR
    mkdir "$TARGET_BINUTILS_DIR/build-spu"
    cd $TARGET_BINUTILS_DIR/build-spu
    ../configure \
	--build=$BUILD_ARCH \
	--host=$TARGET_ARCH \
	--target=spu \
	--prefix=/usr \
	--exec-prefix=/usr \
	--with-sysroot=/usr/spu \
	--enable-werror=no \
	--enable-64-bit-bfd \
	--disable-debug \
	--disable-shared \
	--program-prefix=spu- || error "configure"
    make $MAKEARGS MAKEINFO=true || error "make"

    install_fakeroot_init MAKEINFO=true

    for f in fakeroot/usr/spu/bin/*; do
	test -f $f && ln -sf ../../bin/spu-`basename $f` $f
    done

    install_fakeroot_finish || error
    popd
    touch "$STATE_DIR/target-binutils-spu"
}

build_target_gcc_spu() {
    test -e "$STATE_DIR/target-gcc-spu" && return
    banner "Build gcc $GCC spu"
    echo "configure"
    pushd $TOP_DIR

    mkdir "$TARGET_GCC_DIR/build-spu"
    cd $TARGET_GCC_DIR/build-spu

    ../configure \
	--build=$BUILD_ARCH \
	--host=$TARGET_ARCH \
	--target=spu \
	--prefix=/usr \
	--exec-prefix=/usr \
	--with-build-sysroot=$TOOLCHAIN_SYSROOT \
	--libexecdir=/usr/lib \
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
	--with-gmp=$TARGET_BIN_DIR \
	--with-mpfr=$TARGET_BIN_DIR \
	--disable-bootstrap || error "configure"
    make $MAKEARGS MAKEINFO=true includedir=/xxx || error "make"

    make MAKEINFO=true DESTDIR=${TARGET_GCC_DIR}/build-spu/fakeroot install || error "make install"

    rm -rf fakeroot/info fakeroot/man fakeroot/share

    ln -sf spu-g++ fakeroot/usr/bin/spu-c++
    ln -sf spu-gcc fakeroot/usr/bin/spu-cc

    $STRIP fakeroot/usr/bin/*
    rm -f fakeroot/usr/spu/lib/*.la

    mkdir -p fakeroot/usr/spu/include
    mkdir -p fakeroot/usr/spu/lib

    cp -a $TOOLCHAIN_SYSROOT/usr/spu/include/* fakeroot/usr/spu/include/
    cp -a $TOOLCHAIN_SYSROOT/usr/spu/lib/*     fakeroot/usr/spu/lib/

    $STRIP fakeroot/usr/lib/gcc/spu/${TARGET_GCC_VERSION}/cc1
    $STRIP fakeroot/usr/lib/gcc/spu/${TARGET_GCC_VERSION}/cc1plus
    $STRIP fakeroot/usr/lib/gcc/spu/${TARGET_GCC_VERSION}/collect2

    rm -f fakeroot/usr/lib/libiberty.a
    rm -rf fakeroot/usr/man
    rm -rf fakeroot/usr/info

    ln -sf spu-gcc fakeroot/usr/bin/spu-gcc-${TARGET_GCC_VERSION}
    ln -sf spu-g++ fakeroot/usr/bin/spu-g++-${TARGET_GCC_VERSION}

    for f in as cpp embedspu g++ gcc ld; do
	if [ -e $TOOLCHAIN_SYSROOT/lib64 ]; then
	    ln -sf $f fakeroot/usr/bin/ppu-$f
	else
	    ln -sf $f fakeroot/usr/bin/ppu32-$f
	fi
    done

    install_fakeroot_finish || error

    popd
    touch "$STATE_DIR/target-gcc-spu"
}

build_target_binutils_spu
build_target_gcc_spu
