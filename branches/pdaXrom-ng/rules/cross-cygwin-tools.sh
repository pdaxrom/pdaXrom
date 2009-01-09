BINUTILS="binutils-20080624-2-src.tar.bz2"
BINUTILS_MIRROR="http://mirrors.dotsrc.org/cygwin/release/binutils"
BINUTILS_DIR="$HOST_BUILD_DIR/binutils-20080624-2"

GCC="gcc-core-3.4.4-3-src.tar.bz2"
GPP="gcc-g++-3.4.4-3-src.tar.bz2"
GPP_BIN="gcc-g++-3.4.4-3.tar.bz2"
GCC_MIRROR="http://mirrors.dotsrc.org/cygwin/release/gcc/gcc-core"
GPP_MIRROR="http://mirrors.dotsrc.org/cygwin/release/gcc/gcc-g++"
GCC_DIR="$HOST_BUILD_DIR/gcc-3.4.4"

build_binutils() {
    test -e "$STATE_DIR/host-binutils-cygwin" && return
    banner "Build binutils $BINUTILS"
    download $BINUTILS_MIRROR $BINUTILS
    extract_host $BINUTILS
    apply_patches $BINUTILS_DIR $BINUTILS
    echo "configure"
    pushd $TOP_DIR
    mkdir "$BINUTILS_DIR/build"
    cd $BINUTILS_DIR/build
    sed -i 's|${tooldir}/lib/w32api|${TARGET_SYSTEM_ROOT}/usr/lib/w32api|' ../ld/configure.tgt
    ../configure --target=$TARGET_ARCH --prefix=$TOOLCHAIN_PREFIX --exec-prefix=$TOOLCHAIN_PREFIX \
	--with-sysroot=$TOOLCHAIN_SYSROOT --disable-werrno \
	--enable-build-warnings=",-Wno-error" \
	--disable-debug --disable-shared || error "configure"
    make $MAKEARGS LIB_PATH=$TOOLCHAIN_SYSROOT/usr/lib/w32api || error "make"
    make $MAKEARGS LIB_PATH=$TOOLCHAIN_SYSROOT/usr/lib/w32api install || error "make install"
    popd
    touch "$STATE_DIR/host-binutils-cygwin"
}

SYSROOT_FILES_MIRROR="http://mirrors.dotsrc.org/cygwin/release"
SYSROOT_FILES=" \
cygwin/cygwin-1.5.25-15.tar.bz2 \
w32api/w32api-3.13-1.tar.bz2 \
"

build_sysroot() {
    test -e "$STATE_DIR/cygwin-sysroot" && return
    mkdir -p $TOOLCHAIN_SYSROOT
    for f in $SYSROOT_FILES; do
	download ${SYSROOT_FILES_MIRROR}/${f/\/*} ${f/*\//}
	tar jxf ${SRC_DIR}/${f/*\//} -C $TOOLCHAIN_SYSROOT || error
    done
    touch "$STATE_DIR/cygwin-sysroot"
}

build_gcc() {
    test -e "$STATE_DIR/host-gcc-cygwin" && return
    banner "Build gcc $GCC"
    download $GCC_MIRROR $GCC
    download $GPP_MIRROR $GPP
    download $GPP_MIRROR $GPP_BIN
    extract_host $GCC
    extract_host $GPP
    ###
    ### Extract and patch cygwin gcc/g++ sources
    ###
    local f=
    for f in $HOST_BUILD_DIR/gcc-*.tar.bz2 ; do
	echo "Extracting $f"
	tar jxf $f -C $HOST_BUILD_DIR || error "$f"
    done
    pushd .
    cd $GCC_DIR
    for f in $HOST_BUILD_DIR/gcc-*.patch ; do
	echo "Patching $f"
	cat "$f" | patch -f -p1 || true
    done
    popd
    ###
    apply_patches $GCC_DIR $GCC
    sed -i "s|target-gperf target-libstdc++-v3|target-gperf |" configure
    echo "configure"
    pushd $TOP_DIR
    mkdir -p $GCC_DIR/build
    cd $GCC_DIR/build
    ../configure --target=$TARGET_ARCH --prefix=$TOOLCHAIN_PREFIX --exec-prefix=$TOOLCHAIN_PREFIX \
	--libexecdir=$TOOLCHAIN_PREFIX/lib \
	--with-sysroot=$TOOLCHAIN_SYSROOT --enable-version-specific-runtime-libs --without-x \
	--with-system-zlib --enable-interpreter --disable-win32-registry \
	--enable-sjlj-exceptions --enable-hash-synchronization --enable-libstdcxx-debug
    make $MAKEARGS || error "make"
    make $MAKEARGS install || error "make install"
    mkdir cygpp
    tar jxf $SRC_DIR/$GPP_BIN -C cygpp
    mkdir -p $TOOLCHAIN_PREFIX/lib/gcc/${TARGET_ARCH}/3.4.4/debug || error
    cp -R cygpp/usr/lib/gcc/i686-pc-cygwin/3.4.4/*.a $TOOLCHAIN_PREFIX/lib/gcc/${TARGET_ARCH}/3.4.4/ || error
    cp -R cygpp/usr/lib/gcc/i686-pc-cygwin/3.4.4/include/c++ $TOOLCHAIN_PREFIX/lib/gcc/${TARGET_ARCH}/3.4.4/include/ || error
    cp -R cygpp/usr/lib/gcc/i686-pc-cygwin/3.4.4/debug/*.a $TOOLCHAIN_PREFIX/lib/gcc/${TARGET_ARCH}/3.4.4/debug/ || error

    local tools="ar as c++ cc cpp dlltool dllwrap g++ gcc ld nm objcopy objdump ranlib size strings strip windmc windres"
    local f=

    ln -sf ${TARGET_ARCH}-gcc $TOOLCHAIN_PREFIX/bin/${TARGET_ARCH}-cc

    mkdir -p $TOOLCHAIN_PREFIX/xbin

    for f in $tools; do
	ln -sf ../bin/${TARGET_ARCH}-${f} $TOOLCHAIN_PREFIX/xbin/$f
    done

    popd
    touch "$STATE_DIR/host-gcc-cygwin"
}

build_binutils
build_sysroot
build_gcc
