BINUTILS="binutils-20080624-2-src.tar.bz2"
BINUTILS_MIRROR="http://mirrors.dotsrc.org/cygwin/release/binutils"
BINUTILS_DIR="$HOST_BUILD_DIR/binutils-20080624-2"

GCC="gcc-core-3.4.4-3-src.tar.bz2"
GPP="gcc-g++-3.4.4-3-src.tar.bz2"
GPP_BIN="gcc-g++-3.4.4-3.tar.bz2"
GCC_MIRROR="http://mirrors.dotsrc.org/cygwin/release/gcc/gcc-core"
GPP_MIRROR="http://mirrors.dotsrc.org/cygwin/release/gcc/gcc-g++"
GCC_DIR="$HOST_BUILD_DIR/gcc-3.4.4"

MGW_GCC="gcc-mingw-core-20050522-1.tar.bz2"
MGW_GPP="gcc-mingw-g++-20050522-1.tar.bz2"
MGW_GCC_MIRROR="http://mirrors.dotsrc.org/cygwin/release/gcc-mingw/gcc-mingw-core"
MGW_GPP_MIRROR="http://mirrors.dotsrc.org/cygwin/release/gcc-mingw/gcc-mingw-g++"

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
bzip2/bzip2-1.0.5-2.tar.bz2 \
bzip2/libbz2-devel/libbz2-devel-1.0.5-2.tar.bz2 \
bzip2/libbz2_1/libbz2_1-1.0.5-2.tar.bz2	\
cygwin/cygwin-1.5.25-15.tar.bz2 \
jpeg/jpeg-6b-12.tar.bz2 \
jpeg/libjpeg-devel/libjpeg-devel-6b-12.tar.bz2 \
jpeg/libjpeg62/libjpeg62-6b-12.tar.bz2 \
libpng/libpng-1.2.12-1.tar.bz2 \
libpng/libpng12-devel/libpng12-devel-1.2.12-1.tar.bz2 \
libpng/libpng12/libpng12-1.2.12-1.tar.bz2 \
openssl/openssl-0.9.8j-1.tar.bz2 \
openssl/openssl-devel/openssl-devel-0.9.8j-1.tar.bz2 \
w32api/w32api-3.13-1.tar.bz2 \
zlib/zlib-1.2.3-2.tar.bz2 \
mingw-runtime/mingw-runtime-3.15.1-1.tar.bz2 \
mingw/mingw-bzip2/mingw-bzip2-1.0.5-2.tar.bz2 \
mingw/mingw-bzip2/mingw-libbz2_1/mingw-libbz2_1-1.0.5-2.tar.bz2	\
mingw/mingw-zlib/mingw-zlib-1.2.3-2.tar.bz2 \
"

build_sysroot() {
    test -e "$STATE_DIR/cygwin-sysroot" && return
    mkdir -p $SRC_DIR/cygwin
    mkdir -p $TOOLCHAIN_SYSROOT
    local d=
    local n=
    for f in $SYSROOT_FILES; do
	d=`dirname $f`
	n=`basename $f`
	echo "Download $f"
	mkdir -p ${SRC_DIR}/cygwin/${d}
	test -e ${SRC_DIR}/cygwin/${d}/${n} || \
	    wget ${SYSROOT_FILES_MIRROR}/${f} -O ${SRC_DIR}/cygwin/${d}/${n} || error "Download $f"
	tar jxf ${SRC_DIR}/cygwin/${d}/${n} -C $TOOLCHAIN_SYSROOT || error
    done
    touch "$STATE_DIR/cygwin-sysroot"
}

build_gcc() {
    test -e "$STATE_DIR/host-gcc-cygwin" && return
    banner "Build gcc $GCC"
    download $GCC_MIRROR $GCC
    download $GPP_MIRROR $GPP
    download $GPP_MIRROR $GPP_BIN
    download $MGW_GCC_MIRROR $MGW_GCC
    download $MGW_GPP_MIRROR $MGW_GPP
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

    #
    # cygwin mingw32 support
    #
    tar jxf $SRC_DIR/$MGW_GCC -C cygpp || error
    tar jxf $SRC_DIR/$MGW_GPP -C cygpp || error
    tar zxf cygpp/etc/postinstall/gcc-mingw-core-3.4.4-20050522-1.tgz -C cygpp || error
    tar zxf cygpp/etc/postinstall/gcc-mingw-g++-3.4.4-20050522-1.tgz -C cygpp || error
    mkdir -p $TOOLCHAIN_PREFIX/lib/gcc/${TARGET_ARCH/-cygwin*}-mingw32/3.4.4/debug
    cp -R cygpp/lib/gcc/i686-pc-mingw32/3.4.4/include $TOOLCHAIN_PREFIX/lib/gcc/${TARGET_ARCH/-cygwin*}-mingw32/3.4.4/ || error
    cp -R cygpp/lib/gcc/i686-pc-mingw32/3.4.4/install-tools $TOOLCHAIN_PREFIX/lib/gcc/${TARGET_ARCH/-cygwin*}-mingw32/3.4.4/ || error
    mv $TOOLCHAIN_PREFIX/lib/gcc/${TARGET_ARCH/-cygwin*}-mingw32/3.4.4/include/c++/i686-pc-mingw32 $TOOLCHAIN_PREFIX/lib/gcc/${TARGET_ARCH/-cygwin*}-mingw32/3.4.4/include/c++/${TARGET_ARCH/-cygwin*}-mingw32 || error
    cp -R cygpp/lib/gcc/i686-pc-mingw32/3.4.4/debug/*.a $TOOLCHAIN_PREFIX/lib/gcc/${TARGET_ARCH/-cygwin*}-mingw32/3.4.4/debug/ || error
    cp -R cygpp/lib/gcc/i686-pc-mingw32/3.4.4/*.a $TOOLCHAIN_PREFIX/lib/gcc/${TARGET_ARCH/-cygwin*}-mingw32/3.4.4/ || error 
    cp -R cygpp/lib/gcc/i686-pc-mingw32/3.4.4/*.o $TOOLCHAIN_PREFIX/lib/gcc/${TARGET_ARCH/-cygwin*}-mingw32/3.4.4/ || error 
    ln -sf ../../${TARGET_ARCH}/3.4.4/cc1 $TOOLCHAIN_PREFIX/lib/gcc/${TARGET_ARCH/-cygwin*}-mingw32/3.4.4/
    ln -sf ../../${TARGET_ARCH}/3.4.4/cc1plus $TOOLCHAIN_PREFIX/lib/gcc/${TARGET_ARCH/-cygwin*}-mingw32/3.4.4/
    ln -sf ../../${TARGET_ARCH}/3.4.4/collect2 $TOOLCHAIN_PREFIX/lib/gcc/${TARGET_ARCH/-cygwin*}-mingw32/3.4.4/

    mkdir -p $TOOLCHAIN_PREFIX/${TARGET_ARCH/-cygwin*}-mingw32
    ln -sf ../${TARGET_ARCH}/bin $TOOLCHAIN_PREFIX/${TARGET_ARCH/-cygwin*}-mingw32/ || error
    ln -sf ../../sysroot/usr/include/mingw $TOOLCHAIN_PREFIX/${TARGET_ARCH/-cygwin*}-mingw32/include || error
    ln -sf ../../sysroot/usr/lib/mingw $TOOLCHAIN_PREFIX/${TARGET_ARCH/-cygwin*}-mingw32/lib || error

    popd
    touch "$STATE_DIR/host-gcc-cygwin"
}

build_binutils
build_sysroot
build_gcc
