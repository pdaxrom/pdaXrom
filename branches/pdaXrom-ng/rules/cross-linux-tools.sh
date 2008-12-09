BINUTILS="binutils-2.19.50.0.1.tar.bz2"
BINUTILS_MIRROR="ftp://ftp.kernel.org/pub/linux/devel/binutils"
BINUTILS_DIR="$BUILD_DIR/binutils-2.19.50.0.1"

build_binutils() {
    test -e "$STATE_DIR/binutils" && return
    banner "Build binutils $BINUTILS"
    download $BINUTILS_MIRROR $BINUTILS
    extract $BINUTILS
    apply_patches $BINUTILS_DIR $BINUTILS
    echo "configure"
    pushd $TOP_DIR
    mkdir "$BINUTILS_DIR/build"
    cd $BINUTILS_DIR/build
    ../configure --target=$TARGET_ARCH --prefix=$TOOLCHAIN_PREFIX \
	--exec-prefix=$TOOLCHAIN_PREFIX --with-sysroot=$TOOLCHAIN_SYSROOT \
	--enable-werror=no --enable-64-bit-bfd --disable-debug \
	--disable-shared || error "configure"
    make $MAKEARGS MAKEINFO=true || error "make"
    make $MAKEARGS MAKEINFO=true install || error "make install"
    popd
    touch "$STATE_DIR/binutils"
}

build_binutils

SYSROOT_BIN_MIRROR=ftp://ftp.pld-linux.org/dists/3.0/PLD/i686/RPMS
#SYSTROOT_GLIBC_VERSION=2.9-1
SYSROOT_FILES="
glibc-2.9-1.i686.rpm
glibc-devel-2.9-1.i686.rpm
glibc-devel-utils-2.9-1.i686.rpm
glibc-headers-2.9-1.i686.rpm
glibc-pic-2.9-1.i686.rpm
glibc-static-2.9-1.i686.rpm
gmp-4.2.3-1.i686.rpm
gmp-devel-4.2.3-1.i686.rpm
mpfr-2.3.1-1.i686.rpm
mpfr-devel-2.3.1-1.i686.rpm
linux-libc-headers-2.6.27-1.i686.rpm
"

install_sysroot() {
    test -e "$STATE_DIR/sysroot" && return
    mkdir -p $TOOLCHAIN_SYSROOT
    local f=
    for f in $SYSROOT_FILES ; do
	download $SYSROOT_BIN_MIRROR $f
	pushd $TOP_DIR
	cd $TOOLCHAIN_SYSROOT && rpm2cpio $SRC_DIR/$f | lzma -d | $CPIO -idmu || error "unpack sysroot rpm"
	popd
    done

    local d=
    local l=
    local link=
    for l in `find $TOOLCHAIN_SYSROOT/usr/lib -type l`; do
	link=`readlink $l`
	d=`dirname $link`
	f=`basename $link`
	if [ "$d" = "/lib" ]; then
	    ln -sf ../../lib/$f $l
	elif [ "$d" = "/usr/lib" ]; then
	    ln -sf $f $l
	fi
    done

    touch "$STATE_DIR/sysroot"
}

install_sysroot

GCC="gcc-4.3.2.tar.bz2"
GCC_MIRROR="ftp://gcc.gnu.org/pub/gcc/releases/gcc-4.3"
GCC_DIR="$BUILD_DIR/gcc-4.3.2"

build_gcc() {
    test -e "$STATE_DIR/gcc" && return
    banner "Build gcc $GCC"
    download $GCC_MIRROR $GCC
    extract $GCC
    apply_patches $GCC_DIR $GCC
    echo "configure"
    pushd $TOP_DIR
    mkdir "$GCC_DIR/build"
    cd $GCC_DIR/build
    ../configure --target=$TARGET_ARCH --prefix=$TOOLCHAIN_PREFIX \
	--exec-prefix=$TOOLCHAIN_PREFIX --with-sysroot=$TOOLCHAIN_SYSROOT \
	--enable-threads=posix \
	--enable-linux-futex \
	--enable-languages=c,c++ \
	--enable-libgomp \
	--enable-libmudflap \
	--enable-c99 \
	--enable-long-long \
	--disable-multilib \
	--enable-nls \
	--disable-werror \
	--disable-cld \
	--with-gnu-as \
	--with-gnu-ld \
	--with-demangler-in-ld \
	--with-system-zlib \
	--without-system-libunwind \
	--enable-cmath \
	--with-long-double-128 \
	--disable-libstdcxx-pch \
	--enable-__cxa_atexit \
	--enable-libstdcxx-allocator=new \
	--with-gmp=$HOST_BIN_DIR \
	--with-mpfr=$HOST_BIN_DIR \
	--disable-bootstrap || error "configure"
    make $MAKEARGS MAKEINFO=true || error "make"
    make MAKEINFO=true install || error "make install"
    popd

    ln -sf ${TARGET_ARCH}-gcc $TOOLCHAIN_PREFIX/bin/${TARGET_ARCH}-cc

    local tools="ar as c++ cc cpp g++ gcc ld nm objcopy objdump ranlib readelf size strings strip"
    local f=

    mkdir -p $TOOLCHAIN_PREFIX/xbin

    for f in $tools; do
	ln -sf ../bin/${TARGET_ARCH}-$f $TOOLCHAIN_PREFIX/xbin/$f
    done

    touch "$STATE_DIR/gcc"
}

build_gcc
