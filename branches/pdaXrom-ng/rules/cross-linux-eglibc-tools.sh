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

get_kernel_subarch() {
    case $1 in
    i386*|i486*|i586*|i686*)
	echo i386
	;;
    x86_64*|amd64*)
	echo i386
	;;
    arm*|xscale*)
	echo arm
	;;
    powerpc*|ppc*)
	echo powerpc
	;;
    *)
	echo $1
	;;
    esac
}

if [ "x$KERNEL_VERSION" = "x" ]; then
KERNEL_VERSION="2.6.27"
fi

KERNEL=linux-${KERNEL_VERSION}.tar.bz2
KERNEL_MIRROR=http://kernel.org/pub/linux/kernel/v2.6
KERNEL_DIR=$BUILD_DIR/linux-${KERNEL_VERSION}

install_linux_headers() {
    test -e "$STATE_DIR/linux_kernel_headers" && return
    banner "Build $KERNEL"
    download $KERNEL_MIRROR $KERNEL
    extract $KERNEL
    apply_patches $KERNEL_DIR $KERNEL
    pushd $TOP_DIR
    cd $KERNEL_DIR

    local SUBARCH=`get_kernel_subarch $TARGET_ARCH`
    make SUBARCH=$SUBARCH CROSS_COMPILE=${CROSS} defconfig $MAKEARGS || error
    case $TARGET_ARCH in
    arm*-*eabi*)
	echo "CONFIG_AEABI=y" >> .config
	echo "CONFIG_OABI_COMPAT=y" >> .config
	make SUBARCH=$SUBARCH CROSS_COMPILE=${CROSS} oldconfig $MAKEARGS || error
	;;
    esac
    make SUBARCH=$SUBARCH CROSS_COMPILE=${CROSS} headers_install INSTALL_HDR_PATH=$TOOLCHAIN_SYSROOT/usr $MAKEARGS || error

    popd
    touch "$STATE_DIR/linux_kernel_headers"
}

GLIBC=eglibc-2.8
GLIBC_MIRROR=svn://svn.eglibc.org/branches/eglibc-2_8
GLIBC_DIR="$BUILD_DIR/$GLIBC"
install_glibc_headers() {
    test -e "$STATE_DIR/glibc_headers" && return

    banner "Build initial glibc headers ($GLIBC)"

    if test ! -e "$STATE_DIR/glibc.src-installed" ; then
	download_svn $GLIBC_MIRROR $GLIBC
	cp -R $SRC_DIR/$GLIBC/libc $GLIBC_DIR || error
	cp -R $SRC_DIR/$GLIBC/ports $GLIBC_DIR/ || error
	#cp -R $SRC_DIR/$GLIBC/linuxthreads $GLIBC_DIR/ || error
	#cp -R $SRC_DIR/$GLIBC/localedef $GLIBC_DIR/ || error
	apply_patches $GLIBC_DIR $GLIBC
	touch "$STATE_DIR/glibc.src-installed"
    fi
    pushd $TOP_DIR

    mkdir -p $GLIBC_DIR/build0
    cd $GLIBC_DIR/build0
    
    ../configure \
	--build=$BUILD_ARCH --host=$TARGET_ARCH \
	--prefix=/usr \
	--disable-profile \
	--without-gd \
	--without-cvs \
	--enable-add-ons \
	--enable-kernel=2.6.14 || error

    make $MAKEARGS install_root=$TOOLCHAIN_SYSROOT install-bootstrap-headers=yes install-headers || error
    
    popd
    touch "$STATE_DIR/glibc_headers"
}

build_glibc_stage1() {
    test -e "$STATE_DIR/glibc_installed1" && return

    banner "Build glibc stage 1 ($GLIBC)"

    pushd $TOP_DIR

    mkdir -p $GLIBC_DIR/build1
    cd $GLIBC_DIR/build1
    
    ../configure \
	--build=$BUILD_ARCH --host=$TARGET_ARCH \
	--prefix=/usr \
	--disable-profile \
	--without-gd \
	--without-cvs \
	--enable-add-ons \
	--enable-kernel=2.6.14 || error

    make $MAKEARGS || error
    make $MAKEARGS install_root=$TOOLCHAIN_SYSROOT install || error

    touch "$STATE_DIR/glibc_installed1"
}

build_glibc_stage2() {
    test -e "$STATE_DIR/glibc_installed2" && return

    banner "Build final glibc ($GLIBC)"

    pushd $TOP_DIR

    mkdir -p $GLIBC_DIR/build2
    cd $GLIBC_DIR/build2
    
    ../configure \
	--build=$BUILD_ARCH --host=$TARGET_ARCH \
	--prefix=/usr \
	--disable-profile \
	--without-gd \
	--without-cvs \
	--enable-add-ons \
	--enable-kernel=2.6.14 || error

    make $MAKEARGS || error
    make $MAKEARGS install_root=$TOOLCHAIN_SYSROOT install || error

    touch "$STATE_DIR/glibc_installed2"
}

GCC="gcc-4.3.2.tar.bz2"
GCC_MIRROR="ftp://gcc.gnu.org/pub/gcc/releases/gcc-4.3.2"
GCC_DIR="$BUILD_DIR/gcc-4.3.2"

build_gcc_bootstrap() {
    test -e "$STATE_DIR/gcc_bootstrap" && return
    banner "Build gcc $GCC for configure glibc headers"
    download $GCC_MIRROR $GCC
    extract $GCC
    apply_patches $GCC_DIR $GCC
    local CONF_ARGS=""
    local CONF_CPU=""
    case $TARGET_ARCH in
    powerpc*-*|ppc*-*)
	CONF_ARGS="--enable-secureplt \
		    --enable-targets=powerpc-linux,powerpc64-linux \
		    --with-cpu=default32 \
		    --with-long-double-128"
	;;
    i*86-*)
	if [ "x$DEFAULT_CPU" = "x" ]; then
	    DEFAULT_CPU=${TARGET_ARCH/-*/}
	fi
	CONF_ARGS="--disable-cld \
		    --with-arch=${DEFAULT_CPU} \
		    --with-long-double-128"
	;;
    arm*)
	CONF_ARGS=""
	;;
    *)
	error "Unknown arch"
	;;
    esac
    echo "configure"
    pushd $TOP_DIR
    mkdir "$GCC_DIR/build_bootstr"
    cd $GCC_DIR/build_bootstr
    ../configure --target=$TARGET_ARCH --prefix=$TOOLCHAIN_PREFIX \
	--exec-prefix=$TOOLCHAIN_PREFIX --with-sysroot=$TOOLCHAIN_SYSROOT \
	--libexecdir=$TOOLCHAIN_PREFIX/lib \
	--without-headers \
	--with-newlib \
	--disable-decimal-float \
	--disable-libffi \
	--enable-linux-futex \
	--disable-threads \
	--disable-shared \
	--enable-languages=c \
	--enable-c99 \
	--enable-long-long \
	--enable-cmath \
	--disable-libgomp \
	--disable-libssp \
	--disable-libmudflap \
	--disable-multilib \
	--disable-nls \
	--disable-werror \
	--with-gnu-as \
	--with-gnu-ld \
	--with-system-zlib \
	--disable-libstdcxx-pch \
	--enable-__cxa_atexit \
	--with-gmp=$HOST_BIN_DIR \
	--with-mpfr=$HOST_BIN_DIR \
	$CONF_ARGS \
	--disable-bootstrap || error "configure"
    make $MAKEARGS MAKEINFO=true || error "make"
    make MAKEINFO=true install || error "make install"
    popd

    ln -sf ${TARGET_ARCH}-gcc $TOOLCHAIN_PREFIX/bin/${TARGET_ARCH}-cc

    touch "$STATE_DIR/gcc_bootstrap"
}

build_gcc_stage1() {
    test -e "$STATE_DIR/gcc_stage1" && return
    banner "Build gcc $GCC stage 1"
    local CONF_ARGS=""
    local CONF_CPU=""
    case $TARGET_ARCH in
    powerpc*-*|ppc*-*)
	CONF_ARGS="--enable-secureplt \
		    --enable-targets=powerpc-linux,powerpc64-linux \
		    --with-cpu=default32 \
		    --with-long-double-128"
	;;
    i*86-*)
	if [ "x$DEFAULT_CPU" = "x" ]; then
	    DEFAULT_CPU=${TARGET_ARCH/-*/}
	fi
	CONF_ARGS="--disable-cld \
		    --with-arch=${DEFAULT_CPU} \
		    --with-long-double-128"
	;;
    arm*)
	CONF_ARGS=""
	;;
    *)
	error "Unknown arch"
	;;
    esac
    echo "configure"
    pushd $TOP_DIR
    mkdir "$GCC_DIR/build_stage1"
    cd $GCC_DIR/build_stage1
    ../configure --target=$TARGET_ARCH --prefix=$TOOLCHAIN_PREFIX \
	--exec-prefix=$TOOLCHAIN_PREFIX --with-sysroot=$TOOLCHAIN_SYSROOT \
	--libexecdir=$TOOLCHAIN_PREFIX/lib \
	--enable-linux-futex \
	--disable-threads \
	--disable-shared \
	--enable-languages=c \
	--enable-c99 \
	--enable-long-long \
	--enable-cmath \
	--disable-libgomp \
	--disable-libssp \
	--disable-libmudflap \
	--disable-multilib \
	--disable-nls \
	--disable-werror \
	--with-gnu-as \
	--with-gnu-ld \
	--with-system-zlib \
	--disable-libstdcxx-pch \
	--enable-__cxa_atexit \
	--with-gmp=$HOST_BIN_DIR \
	--with-mpfr=$HOST_BIN_DIR \
	$CONF_ARGS \
	--disable-bootstrap || error "configure"
    make $MAKEARGS MAKEINFO=true || error "make"
    make MAKEINFO=true install || error "make install"
    popd

    # hack for libgcc_eh.a
    ln -sv libgcc.a `${TARGET_ARCH}-gcc -print-search-dirs | head -n 1 | awk '{ print $2 }'`libgcc_eh.a

    ln -sf ${TARGET_ARCH}-gcc $TOOLCHAIN_PREFIX/bin/${TARGET_ARCH}-cc

    touch "$STATE_DIR/gcc_stage1"
}

build_gcc() {
    test -e "$STATE_DIR/gcc" && return
    banner "Build gcc $GCC"
    local CONF_ARGS=""
    case $TARGET_ARCH in
    powerpc*-*|ppc*-*)
	CONF_ARGS="--enable-secureplt \
		    --enable-targets=powerpc-linux,powerpc64-linux \
		    --with-cpu=default32 \
		    --enable-libgomp \
		    --with-long-double-128"
	;;
    i*86-*)
	if [ "x$DEFAULT_CPU" = "x" ]; then
	    DEFAULT_CPU=${TARGET_ARCH/-*/}
	fi
	CONF_ARGS="--disable-cld \
		    --with-arch=${DEFAULT_CPU} \
		    --with-long-double-128"
	;;
    arm*)
	CONF_ARGS="--disable-libgomp"
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
	--exec-prefix=$TOOLCHAIN_PREFIX --with-sysroot=$TOOLCHAIN_SYSROOT \
	--libexecdir=$TOOLCHAIN_PREFIX/lib \
	--enable-linux-futex \
	--enable-threads \
	--enable-shared \
	--enable-languages=c,c++ \
	--enable-c99 \
	--enable-long-long \
	--enable-cmath \
	--disable-libssp \
	--disable-libmudflap \
	--disable-multilib \
	--disable-nls \
	--disable-werror \
	--with-gnu-as \
	--with-gnu-ld \
	--with-system-zlib \
	--disable-libstdcxx-pch \
	--enable-__cxa_atexit \
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

    touch "$STATE_DIR/gcc"
}

build_binutils

install_linux_headers

build_gcc_bootstrap

install_glibc_headers

build_gcc_stage1

build_glibc_stage1

build_gcc

build_glibc_stage2
