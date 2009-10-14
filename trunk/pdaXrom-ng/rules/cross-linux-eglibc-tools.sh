BINUTILS="binutils-${BINUTILS_VERSION-2.19.50.0.1}.tar.bz2"
BINUTILS_MIRROR="ftp://ftp.kernel.org/pub/linux/devel/binutils"
BINUTILS_DIR="$BUILD_DIR/binutils-${BINUTILS_VERSION-2.19.50.0.1}"

build_binutils() {
    test -e "$STATE_DIR/binutils" && return
    banner "Build binutils $BINUTILS"
    download $BINUTILS_MIRROR $BINUTILS
    extract $BINUTILS
    apply_patches $BINUTILS_DIR $BINUTILS
    local CONF_ARGS=
    case $TARGET_ARCH in
    powerpc*|ppc*)
	CONF_ARGS="--enable-targets=spu"
	;;
    esac
    echo "configure"
    pushd $TOP_DIR
    mkdir "$BINUTILS_DIR/build"
    cd $BINUTILS_DIR/build
    ../configure --target=$TARGET_ARCH --prefix=$TOOLCHAIN_PREFIX \
	--exec-prefix=$TOOLCHAIN_PREFIX --with-sysroot=$TOOLCHAIN_SYSROOT \
	--enable-werror=no --enable-64-bit-bfd --disable-debug \
	--disable-shared $CONF_ARGS || error "configure"
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
	echo x86_64
	;;
    arm*|xscale*)
	echo arm
	;;
    powerpc*|ppc*)
	echo powerpc
	;;
    mips*)
	echo mips
	;;
    *)
	echo $1
	;;
    esac
}

KERNEL=linux-${KERNEL_VERSION-2.6.27}.tar.bz2
KERNEL_MIRROR=http://kernel.org/pub/linux/kernel/v2.6
KERNEL_DIR=$BUILD_DIR/linux-${KERNEL_VERSION-2.6.27}

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

GLIBC=eglibc-2.9
GLIBC_MIRROR=svn://svn.eglibc.org/branches/eglibc-2_9
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

    cd $GLIBC_DIR

    case $TARGET_ARCH in
    mips*)
	if [ ! "x$DEFAULT_MABI" = "x" ]; then
	    echo "" > ports/sysdeps/mips/mips64/n64/Makefile
	    echo "" > ports/sysdeps/mips/mips64/n32/Makefile
	    echo "" > ports/sysdeps/mips/mips32/Makefile
	    sed -i "/default) machine=/s/n32/${DEFAULT_MABI}/g" ports/sysdeps/mips/preconfigure || error "mips default mabi"
	    true
	fi
	;;
    esac

    mkdir -p $GLIBC_DIR/build0
    cd $GLIBC_DIR/build0
    
    ac_test_x="test -x" \
    as_test_x="test -x" \
    ../configure \
	--build=$BUILD_ARCH --host=$TARGET_ARCH \
	--prefix=/usr \
	--disable-profile \
	--without-gd \
	--without-cvs \
	--enable-add-ons \
	--enable-kernel=${GLIBC_ENABLE_KERNEL-2.6.27} || error "configure build0"

    make $MAKEARGS install_root=$TOOLCHAIN_SYSROOT install-bootstrap-headers=yes install-headers || error "install headers"

    case $TARGET_ARCH in
    powerpc64-*|ppc64-*)
	ln -sf lib64 $TOOLCHAIN_SYSROOT/lib
	ln -sf lib64 $TOOLCHAIN_SYSROOT/usr/lib
	;;
    mips64*-*)
	if [ "$DEFAULT_MABI" = "64"  ]; then
	    ln -sf lib64 $TOOLCHAIN_SYSROOT/lib
	    ln -sf lib64 $TOOLCHAIN_SYSROOT/usr/lib
	else
	    ln -sf lib32 $TOOLCHAIN_SYSROOT/lib
	    ln -sf lib32 $TOOLCHAIN_SYSROOT/usr/lib
	fi
	;;
    esac

    popd
    touch "$STATE_DIR/glibc_headers"
}

build_glibc_stage1() {
    test -e "$STATE_DIR/glibc_installed1" && return

    banner "Build glibc stage 1 ($GLIBC)"

    pushd $TOP_DIR

    mkdir -p $GLIBC_DIR/build1
    cd $GLIBC_DIR/build1

    OPT_CFLAGS=
    OPT_CXXFLAGS=
    if [ ! "x$CROSS_OPT_CFLAGS" = "x" ]; then
	OPT_CFLAGS="CFLAGS=$CROSS_OPT_CFLAGS"
    fi
    if [ ! "x$CROSS_OPT_CXXFLAGS" = "x" ]; then
	OPT_CXXFLAGS="CFLAGS=$CROSS_OPT_CXXFLAGS"
    fi

    BUILD_CC=gcc \
    CC="${TARGET_ARCH}-gcc ${CROSS_OPT_ARCH} ${CROSS_OPT_MABI}" \
    CXX="${TARGET_ARCH}-g++ ${CROSS_OPT_ARCH} ${CROSS_OPT_MABI}" \
    AR=${TARGET_ARCH}-ar \
    RANLIB=${TARGET_ARCH}-ranlib \
    ac_test_x="test -x" \
    as_test_x="test -x" \
    ../configure \
	--build=$BUILD_ARCH --host=$TARGET_ARCH \
	--prefix=/usr \
	--disable-profile \
	--without-gd \
	--without-cvs \
	--enable-add-ons \
	--enable-kernel=${GLIBC_ENABLE_KERNEL-2.6.27} || error

    make $MAKEARGS $OPT_CFLAGS $OPT_CXXFLAGS || error
    make $MAKEARGS $OPT_CFLAGS $OPT_CXXFLAGS install_root=$TOOLCHAIN_SYSROOT install || error

    touch "$STATE_DIR/glibc_installed1"
}

build_glibc_stage2() {
    test -e "$STATE_DIR/glibc_installed2" && return

    banner "Build final glibc ($GLIBC)"

    pushd $TOP_DIR

    mkdir -p $GLIBC_DIR/build2
    cd $GLIBC_DIR/build2

    OPT_CFLAGS=
    OPT_CXXFLAGS=
    if [ ! "x$CROSS_OPT_CFLAGS" = "x" ]; then
	OPT_CFLAGS="CFLAGS=$CROSS_OPT_CFLAGS"
    fi
    if [ ! "x$CROSS_OPT_CXXFLAGS" = "x" ]; then
	OPT_CXXFLAGS="CFLAGS=$CROSS_OPT_CXXFLAGS"
    fi

    BUILD_CC=gcc \
    CC="${TARGET_ARCH}-gcc ${CROSS_OPT_ARCH} ${CROSS_OPT_MABI}" \
    CXX="${TARGET_ARCH}-g++ ${CROSS_OPT_ARCH} ${CROSS_OPT_MABI}" \
    AR=${TARGET_ARCH}-ar \
    RANLIB=${TARGET_ARCH}-ranlib \
    ac_test_x="test -x" \
    as_test_x="test -x" \
    ../configure \
	--build=$BUILD_ARCH --host=$TARGET_ARCH \
	--prefix=/usr \
	--disable-profile \
	--without-gd \
	--without-cvs \
	--enable-add-ons \
	--enable-kernel=${GLIBC_ENABLE_KERNEL-2.6.27} || error

    make $MAKEARGS $OPT_CFLAGS $OPT_CXXFLAGS || error
    make $MAKEARGS $OPT_CFLAGS $OPT_CXXFLAGS install_root=$TOOLCHAIN_SYSROOT install || error

    touch "$STATE_DIR/glibc_installed2"
}

GCC="gcc-${GCC_VERSION-4.3.2}.tar.bz2"
GCC_MIRROR="ftp://gcc.gnu.org/pub/gcc/releases/gcc-${GCC_VERSION-4.3.2}"
GCC_DIR="$BUILD_DIR/gcc-${GCC_VERSION-4.3.2}"

build_gcc_bootstrap() {
    test -e "$STATE_DIR/gcc_bootstrap" && return
    banner "Build gcc $GCC for configure glibc headers"
    download $GCC_MIRROR $GCC
    extract $GCC
    apply_patches $GCC_DIR $GCC
    local CONF_ARGS=""
    local CONF_CPU=""
    case $TARGET_ARCH in
    powerpc-*|ppc-*)
	CONF_ARGS="--enable-secureplt \
		    --enable-targets=powerpc-linux,powerpc64-linux \
		    --with-cpu=${DEFAULT_CPU-default32} \
		    --with-long-double-128"
	;;
    powerpc64-*|ppc64-*)
	CONF_ARGS="--enable-secureplt \
		    --enable-targets=powerpc-linux,powerpc64-linux \
		    --with-cpu=${DEFAULT_CPU-default64} \
		    --with-long-double-128"
	;;
    i*86-*)
	CONF_ARGS="--disable-cld \
		    --with-arch=${DEFAULT_CPU-${TARGET_ARCH/-*/}} \
		    --with-long-double-128"
	;;
    x86_64-*|amd64-*)
	CONF_ARGS="--disable-cld \
		    --with-arch=${DEFAULT_CPU-core2} \
		    --with-long-double-128"
	;;
    arm*)
	CONF_ARGS="--with-arch=${DEFAULT_CPU-armv5te}"

	case $DEFAULT_FPU in
	softvfp)
            CONF_ARGS="$CONF_ARGS --with-float=soft --with-fpu=vfp"
	    ;;
	soft)
            CONF_ARGS="$CONF_ARGS --with-float=soft"
	    ;;
	fpa)
            CONF_ARGS="$CONF_ARGS --with-float=hard"
	    ;;
	vfp)
            CONF_ARGS="$CONF_ARGS --with-fpu=vfp"
	    ;;
	esac
	;;
    mips*)
	if [ ! "x$DEFAULT_MABI" = "x" ]; then
	    CONF_ARGS="$CONF_ARGS --with-abi=${DEFAULT_MABI}"
	fi
	if [ ! "x$DEFAULT_CPU" = "x" ]; then
	    CONF_ARGS="$CONF_ARGS --with-arch=$DEFAULT_CPU"
	fi
	if [ ! "x$DEFAULT_FPU" = "x" ]; then
	    CONF_ARGS="$CONF_ARGS --with-float=$DEFAULT_FPU"
	fi
	CONF_ARGS="$CONF_ARGS --with-mips-plt"
	#CONF_ARGS="$CONF_ARGS --enable-mips-nonpic \
	#	    --enable-extra-sgxxlite-multilibs"
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
    powerpc-*|ppc-*)
	CONF_ARGS="--enable-secureplt \
		    --enable-targets=powerpc-linux,powerpc64-linux \
		    --with-cpu=${DEFAULT_CPU-default32} \
		    --with-long-double-128"
	;;
    powerpc64-*|ppc64-*)
	CONF_ARGS="--enable-secureplt \
		    --enable-targets=powerpc-linux,powerpc64-linux \
		    --with-cpu=${DEFAULT_CPU-default64} \
		    --with-long-double-128"
	;;
    i*86-*)
	CONF_ARGS="--disable-cld \
		    --with-arch=${DEFAULT_CPU-${TARGET_ARCH/-*/}} \
		    --with-long-double-128"
	;;
    x86_64-*|amd64-*)
	CONF_ARGS="--disable-cld \
		    --with-arch=${DEFAULT_CPU-core2} \
		    --with-long-double-128"
	;;
    arm*)
	CONF_ARGS="--with-arch=${DEFAULT_CPU-armv5te}"

	case $DEFAULT_FPU in
	softvfp)
            CONF_ARGS="$CONF_ARGS --with-float=soft --with-fpu=vfp"
	    ;;
	soft)
            CONF_ARGS="$CONF_ARGS --with-float=soft"
	    ;;
	fpa)
            CONF_ARGS="$CONF_ARGS --with-float=hard"
	    ;;
	vfp)
            CONF_ARGS="$CONF_ARGS --with-fpu=vfp"
	    ;;
	esac
	;;
    mips*)
	if [ ! "x$DEFAULT_MABI" = "x" ]; then
	    CONF_ARGS="$CONF_ARGS --with-abi=${DEFAULT_MABI}"
	fi
	if [ ! "x$DEFAULT_CPU" = "x" ]; then
	    CONF_ARGS="$CONF_ARGS --with-arch=$DEFAULT_CPU"
	fi
	if [ ! "x$DEFAULT_FPU" = "x" ]; then
	    CONF_ARGS="$CONF_ARGS --with-float=$DEFAULT_FPU"
	fi
	CONF_ARGS="$CONF_ARGS --with-mips-plt"
	#CONF_ARGS="$CONF_ARGS --enable-mips-nonpic \
	#	    --enable-extra-sgxxlite-multilibs"
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
    powerpc-*|ppc-*)
	CONF_ARGS="--enable-secureplt \
		    --enable-targets=powerpc-linux,powerpc64-linux \
		    --with-cpu=${DEFAULT_CPU-default32} \
		    --enable-libgomp \
		    --with-long-double-128"
	;;
    powerpc64-*|ppc64-*)
	CONF_ARGS="--enable-secureplt \
		    --enable-targets=powerpc-linux,powerpc64-linux \
		    --with-cpu=${DEFAULT_CPU-default64} \
		    --with-long-double-128"
	;;
    i*86-*)
	CONF_ARGS="--disable-cld \
		    --with-arch=${DEFAULT_CPU-${TARGET_ARCH/-*/}} \
		    --enable-libgomp \
		    --with-long-double-128"
	;;
    x86_64-*|amd64-*)
	CONF_ARGS="--disable-cld \
		    --with-arch=${DEFAULT_CPU-core2} \
		    --enable-libgomp \
		    --with-long-double-128"
	;;
    arm*)
	CONF_ARGS="--with-arch=${DEFAULT_CPU-armv5te} \
		    --disable-libgomp"

	case $DEFAULT_FPU in
	softvfp)
            CONF_ARGS="$CONF_ARGS --with-float=soft --with-fpu=vfp"
	    ;;
	soft)
            CONF_ARGS="$CONF_ARGS --with-float=soft"
	    ;;
	fpa)
            CONF_ARGS="$CONF_ARGS --with-float=hard"
	    ;;
	vfp)
            CONF_ARGS="$CONF_ARGS --with-fpu=vfp"
	    ;;
	esac
	;;
    mips*)
	if [ ! "x$DEFAULT_MABI" = "x" ]; then
	    CONF_ARGS="$CONF_ARGS --with-abi=${DEFAULT_MABI}"
	fi
	if [ ! "x$DEFAULT_CPU" = "x" ]; then
	    CONF_ARGS="$CONF_ARGS --with-arch=$DEFAULT_CPU"
	fi
	if [ ! "x$DEFAULT_FPU" = "x" ]; then
	    CONF_ARGS="$CONF_ARGS --with-float=$DEFAULT_FPU"
	fi
	CONF_ARGS="$CONF_ARGS --with-mips-plt"
	#CONF_ARGS="$CONF_ARGS --enable-mips-nonpic \
	#	    --enable-extra-sgxxlite-multilibs"
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

case $TARGET_ARCH in
powerpc*|ppc*)
    . $RULES_DIR/cross-spu.sh
    ;;
esac
