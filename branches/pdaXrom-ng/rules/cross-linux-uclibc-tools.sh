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

get_rpm_target_arch() {
    case $1 in
    powerpc*-*|ppc*-*)
	echo "ppc"
	;;
    i686-*)
	echo "i686"
	;;
    i*86-*)
	echo "i486"
	;;
    x86_64-*|amd64-*)
	echo "x86_64"
	;;
    arm*-*|xscale*-*)
	echo "arm"
	;;
    *)
	echo "unknown"
	;;
    esac
}

SYSROOT_BIN_MIRROR=ftp://ftp.pld-linux.org/dists/3.0/PLD
SYSROOT_FILES="
glibc-devel-2.9-1
glibc-headers-2.9-1
linux-libc-headers-2.6.27-1
"

TOOLCHAIN_SYSROOT_STAGE1=${TOOLCHAIN_SYSROOT}-stage1

install_sysroot() {
    test -e "$STATE_DIR/sysroot-stage1" && return
    mkdir -p $TOOLCHAIN_SYSROOT_STAGE1
    local rpm_arch=`get_rpm_target_arch $TARGET_ARCH`
    local f=
    for f in $SYSROOT_FILES ; do
	download ${SYSROOT_BIN_MIRROR}/${rpm_arch}/RPMS ${f}.${rpm_arch}.rpm
	pushd $TOP_DIR
	cd $TOOLCHAIN_SYSROOT_STAGE1 && rpm2cpio $SRC_DIR/${f}.${rpm_arch}.rpm | lzma -d | $CPIO -idmu || error "unpack sysroot rpm"
	popd
    done
    pushd $TOP_DIR
    f="linux-libc-headers-2.6.27-1"
    mkdir -p $TOOLCHAIN_SYSROOT
    cd $TOOLCHAIN_SYSROOT && rpm2cpio $SRC_DIR/${f}.${rpm_arch}.rpm | lzma -d | $CPIO -idmu || error "unpack sysroot rpm"
    popd
    touch "$STATE_DIR/sysroot-stage1"
}

install_sysroot

GCC="gcc-4.3.2.tar.bz2"
GCC_MIRROR="ftp://gcc.gnu.org/pub/gcc/releases/gcc-4.3.2"
GCC_DIR="$BUILD_DIR/gcc-4.3.2"

build_gcc_stage1() {
    test -e "$STATE_DIR/gcc-stage1" && return
    banner "Build gcc stage1 $GCC"
    download $GCC_MIRROR $GCC
    extract $GCC
    apply_patches $GCC_DIR $GCC
    local CONF_ARGS=""
    case $TARGET_ARCH in
    powerpc*-*|ppc*-*)
	CONF_ARGS="--enable-secureplt \
		    --enable-targets=powerpc-linux,powerpc64-linux \
		    --with-cpu=default32"
	;;
    i*86-*|x86_64-*|amd64-*)
	CONF_ARGS="--disable-cld"
	;;
    *)
	error "Unknown arch"
	;;
    esac
    echo "configure"
    pushd $TOP_DIR
    mkdir "$GCC_DIR/build"
    cd $GCC_DIR/build
    ../configure --target=$TARGET_ARCH --prefix=$TOOLCHAIN_PREFIX \
	--exec-prefix=$TOOLCHAIN_PREFIX --with-sysroot=$TOOLCHAIN_SYSROOT_STAGE1 \
	--enable-threads=posix \
	--enable-languages=c \
	--enable-c99 \
	--enable-long-long \
	--enable-cmath \
	--with-long-double-128 \
	--disable-multilib \
	--disable-nls \
	--disable-werror \
	--with-gnu-as \
	--with-gnu-ld \
	--with-demangler-in-ld \
	--with-system-zlib \
	--disable-__cxa_atexit \
	--enable-target-optspace \
	--with-gmp=$HOST_BIN_DIR \
	--with-mpfr=$HOST_BIN_DIR \
	$CONF_ARGS \
	--disable-shared \
	--disable-libssp \
	--disable-libgomp \
	--disable-libmudflap \
	--disable-bootstrap || error "configure"
    make $MAKEARGS MAKEINFO=true || error "make"
    make MAKEINFO=true install || error "make install"
    popd

    ln -sf ${TARGET_ARCH}-gcc $TOOLCHAIN_PREFIX/bin/${TARGET_ARCH}-cc

    touch "$STATE_DIR/gcc-stage1"
}

build_gcc_stage1

UCLIBC=uClibc-0.9.30.tar.bz2
UCLIBC_MIRROR=http://www.uclibc.org/downloads
UCLIBC_DIR=$BUILD_DIR/uClibc-0.9.30
UCLIBC_ENV="$CROSS_ENV_AC"

build_uClibc() {
    test -e "$STATE_DIR/uClibc.installed" && return
    banner "Build uClibc"
    download $UCLIBC_MIRROR $UCLIBC
    extract $UCLIBC
    apply_patches $UCLIBC_DIR $UCLIBC
    pushd $TOP_DIR
    cd $UCLIBC_DIR

    if [ "x$UCLIBC_CONFIG" = "x" ]; then
	cp $CONFIG_DIR/uClibc/${TARGET_ARCH/-*/}-config .config || error "no uClibc config for ${TARGET_ARCH/-*/}"
    else
	cp $CONFIG_DIR/uClibc/$UCLIBC_CONFIG .config || error "can't copy config, check config name in UCLIBC_CONFIG"
    fi
    
    make $MAKEARGS KERNEL_HEADERS=$TOOLCHAIN_SYSROOT/usr/include CROSS=${CROSS} oldconfig || error
    make $MAKEARGS KERNEL_HEADERS=$TOOLCHAIN_SYSROOT/usr/include CROSS=${CROSS} || error
    make $MAKEARGS KERNEL_HEADERS=$TOOLCHAIN_SYSROOT/usr/include CROSS=${CROSS} PREFIX=$TOOLCHAIN_SYSROOT DEVEL_PREFIX=/usr/ RUNTIME_PREFIX=/ install || error

    popd
    touch "$STATE_DIR/uClibc.installed"
}

build_uClibc

build_gcc() {
    test -e "$STATE_DIR/gcc" && return
    banner "Build gcc $GCC"
    local CONF_ARGS=""
    case $TARGET_ARCH in
    powerpc*-*|ppc*-*)
	CONF_ARGS="--enable-secureplt \
		    --enable-targets=powerpc-linux,powerpc64-linux \
		    --with-cpu=default32"
	;;
    i*86-*|x86_64-*|amd64-*)
	CONF_ARGS="--disable-cld"
	;;
    *)
	error "Unknown arch"
	;;
    esac
    echo "configure"
    pushd $TOP_DIR
    mkdir -p "$GCC_DIR/build2"
    cd $GCC_DIR/build2
    ../configure --target=$TARGET_ARCH --prefix=$TOOLCHAIN_PREFIX \
	--exec-prefix=$TOOLCHAIN_PREFIX --with-sysroot=$TOOLCHAIN_SYSROOT \
	--enable-threads=posix \
	--enable-languages=c,c++ \
	--enable-c99 \
	--enable-long-long \
	--enable-cmath \
	--with-long-double-128 \
	--disable-multilib \
	--enable-nls \
	--disable-werror \
	--with-gnu-as \
	--with-gnu-ld \
	--with-demangler-in-ld \
	--with-system-zlib \
	--enable-__cxa_atexit \
	--enable-target-optspace \
	--with-gmp=$HOST_BIN_DIR \
	--with-mpfr=$HOST_BIN_DIR \
	$CONF_ARGS \
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

    rm -rf ${TOOLCHAIN_SYSROOT}-stage1

    touch "$STATE_DIR/gcc"
}

build_gcc
