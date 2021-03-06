BINUTILS="binutils-${BINUTILS_VERSION-2.19.50.0.1}.tar.bz2"
BINUTILS_MIRROR="http://www.kernel.org/pub/linux/devel/binutils"
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
	echo i386
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

UCLIBC_VERSION=0.9.31
UCLIBC=uClibc-${UCLIBC_VERSION}.tar.bz2
UCLIBC_MIRROR=http://www.uclibc.org/downloads
UCLIBC_DIR=$BUILD_DIR/uClibc-${UCLIBC_VERSION}
UCLIBC_ENV="$CROSS_ENV_AC"

install_uclibc_headers() {
    test -e "$STATE_DIR/uClibc-headers.installed" && return
    banner "Install uClibc headers"
    download $UCLIBC_MIRROR $UCLIBC
    extract $UCLIBC
    apply_patches $UCLIBC_DIR $UCLIBC
    pushd $TOP_DIR
    cd $UCLIBC_DIR

    if [ "x$UCLIBC_CONFIG" = "x" ]; then
	case $TARGET_ARCH in
	arm*el-*eabi*|armle-*)
	    cp $CONFIG_DIR/uClibc/armel-config .config || error "no uClibc config for ${TARGET_ARCH/-*/}"
	    if grep -q "^CONFIG_AEABI=y" $KERNEL_DIR/.config ; then
		sed -i -e "s:CONFIG_ARM_OABI.*:# CONFIG_ARM_OABI is not set:g" .config
		sed -i -e "s:# CONFIG_ARM_EABI.*:CONFIG_ARM_EABI=y:g" .config
	    fi
	    ;;
	arm*eb-*eabi*|armbe-*)
	    cp $CONFIG_DIR/uClibc/armeb-config .config || error "no uClibc config for ${TARGET_ARCH/-*/}"
	    if grep -q "^CONFIG_AEABI=y" $KERNEL_DIR/.config ; then
		sed -i -e "s:CONFIG_ARM_OABI.*:# CONFIG_ARM_OABI is not set:g" .config
		sed -i -e "s:# CONFIG_ARM_EABI.*:CONFIG_ARM_EABI=y:g" .config
	    fi
	    ;;
	i*86-*)
	    cp $CONFIG_DIR/uClibc/x86-config .config || error "no uClibc config for ${TARGET_ARCH/-*/}"
	    ;;
	*)
	    cp $CONFIG_DIR/uClibc/${TARGET_ARCH/-*/}-config .config || error "no uClibc config for ${TARGET_ARCH/-*/}"
	    ;;
	esac
    elif [ -e $BSP_CONFIG_DIR/uClibc/$UCLIBC_CONFIG ]; then
	cp $BSP_CONFIG_DIR/uClibc/$UCLIBC_CONFIG .config || error "can't copy config, check config name in UCLIBC_CONFIG"
    elif [ -e $CONFIG_DIR/uClibc/$UCLIBC_CONFIG ]; then
	cp $CONFIG_DIR/uClibc/$UCLIBC_CONFIG .config || error "can't copy config, check config name in UCLIBC_CONFIG"
    else
	cp $UCLIBC_CONFIG .config || error "can't copy config, check config name in UCLIBC_CONFIG"
    fi

    make $MAKEARGS KERNEL_HEADERS=$TOOLCHAIN_SYSROOT/usr/include oldconfig || error
    make $MAKEARGS KERNEL_HEADERS=$TOOLCHAIN_SYSROOT/usr/include PREFIX=$TOOLCHAIN_SYSROOT DEVEL_PREFIX=/usr/ RUNTIME_PREFIX=/ install_headers || error

    popd
    touch "$STATE_DIR/uClibc-headers.installed"
}

build_uClibc() {
    test -e "$STATE_DIR/uClibc.installed" && return
    banner "Build uClibc"

    pushd $TOP_DIR
    cd $UCLIBC_DIR

    make distclean

    if [ "x$UCLIBC_CONFIG" = "x" ]; then
	case $TARGET_ARCH in
	arm*el-*eabi*|armle-*eabi*)
	    cp $CONFIG_DIR/uClibc/armel-config .config || error "no uClibc config for ${TARGET_ARCH/-*/}"
	    if grep -q "^CONFIG_AEABI=y" $KERNEL_DIR/.config ; then
		sed -i -e "s:CONFIG_ARM_OABI.*:# CONFIG_ARM_OABI is not set:g" .config
		sed -i -e "s:# CONFIG_ARM_EABI.*:CONFIG_ARM_EABI=y:g" .config
	    fi
	    ;;
	arm*eb-*eabi*|armbe-*eabi*)
	    cp $CONFIG_DIR/uClibc/armeb-config .config || error "no uClibc config for ${TARGET_ARCH/-*/}"
	    if grep -q "^CONFIG_AEABI=y" $KERNEL_DIR/.config ; then
		sed -i -e "s:CONFIG_ARM_OABI.*:# CONFIG_ARM_OABI is not set:g" .config
		sed -i -e "s:# CONFIG_ARM_EABI.*:CONFIG_ARM_EABI=y:g" .config
	    fi
	    ;;
	i*86-*)
	    cp $CONFIG_DIR/uClibc/x86-config .config || error "no uClibc config for ${TARGET_ARCH/-*/}"
	    ;;
	*)
	    cp $CONFIG_DIR/uClibc/${TARGET_ARCH/-*/}-config .config || error "no uClibc config for ${TARGET_ARCH/-*/}"
	    ;;
	esac
    elif [ -e $BSP_CONFIG_DIR/uClibc/$UCLIBC_CONFIG ]; then
	cp $BSP_CONFIG_DIR/uClibc/$UCLIBC_CONFIG .config || error "can't copy config, check config name in UCLIBC_CONFIG"
    elif [ -e $CONFIG_DIR/uClibc/$UCLIBC_CONFIG ]; then
	cp $CONFIG_DIR/uClibc/$UCLIBC_CONFIG .config || error "can't copy config, check config name in UCLIBC_CONFIG"
    else
	cp $UCLIBC_CONFIG .config || error "can't copy config, check config name in UCLIBC_CONFIG"
    fi

    make $MAKEARGS KERNEL_HEADERS=$TOOLCHAIN_SYSROOT/usr/include CROSS=${CROSS} oldconfig || error
    make $MAKEARGS KERNEL_HEADERS=$TOOLCHAIN_SYSROOT/usr/include CROSS=${CROSS} PREFIX=$TOOLCHAIN_SYSROOT DEVEL_PREFIX=/usr/ RUNTIME_PREFIX=/ install_headers || error

    make $MAKEARGS KERNEL_HEADERS=$TOOLCHAIN_SYSROOT/usr/include CROSS=${CROSS} || error
    make $MAKEARGS KERNEL_HEADERS=$TOOLCHAIN_SYSROOT/usr/include CROSS=${CROSS} utils || error
    make $MAKEARGS KERNEL_HEADERS=$TOOLCHAIN_SYSROOT/usr/include CROSS=${CROSS} PREFIX=$TOOLCHAIN_SYSROOT DEVEL_PREFIX=/usr/ RUNTIME_PREFIX=/ install || error
    make $MAKEARGS KERNEL_HEADERS=$TOOLCHAIN_SYSROOT/usr/include CROSS=${CROSS} PREFIX=$TOOLCHAIN_SYSROOT DEVEL_PREFIX=/usr/ RUNTIME_PREFIX=/ install_utils || error

    popd
    touch "$STATE_DIR/uClibc.installed"
}

GCC="gcc-${GCC_VERSION-4.3.2}.tar.bz2"
GCC_MIRROR="ftp://gcc.gnu.org/pub/gcc/releases/gcc-${GCC_VERSION-4.3.2}"
GCC_DIR="$BUILD_DIR/gcc-${GCC_VERSION-4.3.2}"

build_gcc_stage1() {
    test -e "$STATE_DIR/gcc-stage1" && return
    banner "Build gcc stage1 $GCC"
    download $GCC_MIRROR $GCC
    extract $GCC
    apply_patches $GCC_DIR `getfilename $GCC`-uclibc
    local CONF_ARGS=""
    case $TARGET_ARCH in
    powerpc*-*|ppc*-*)
	CONF_ARGS="--enable-secureplt \
		    --enable-targets=powerpc-linux,powerpc64-linux \
		    --with-cpu=${DEFAULT_CPU-default32} \
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
            CONF_ARGS="$CONF_ARGS --with-float=softfp --with-fpu=vfp"
	    ;;
	esac
	;;
    mips*)
	CONF_ARGS="--with-arch=${DEFAULT_CPU-mips32r2} \
		    --with-float=hard \
		    --enable-mips-nonpic \
		    --enable-extra-sgxxlite-multilibs"
	;;
    *)
	error "Unknown arch"
	;;
    esac
    if [ ! "$GCC_ENABLE_TLS" = "yes" ]; then
	CONF_ARGS="$CONF_ARGS --disable-tls"
    fi
    CONF_ARGS="$CONF_ARGS $GCC_EXTRA_CONF_ARGS"
    echo "configure"
    pushd $TOP_DIR
    mkdir "$GCC_DIR/build"
    cd $GCC_DIR/build
    ../configure --target=$TARGET_ARCH --prefix=$TOOLCHAIN_PREFIX \
	--exec-prefix=$TOOLCHAIN_PREFIX --with-sysroot=$TOOLCHAIN_SYSROOT \
	--libexecdir=$TOOLCHAIN_PREFIX/lib \
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

build_gcc() {
    test -e "$STATE_DIR/gcc" && return
    banner "Build gcc $GCC"
    local CONF_ARGS=""
    case $TARGET_ARCH in
    powerpc*-*|ppc*-*)
	CONF_ARGS="--enable-secureplt \
		    --enable-targets=powerpc-linux,powerpc64-linux \
		    --with-cpu=${DEFAULT_CPU-default32} \
		    --enable-libgomp \
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
            CONF_ARGS="$CONF_ARGS --with-float=softfp --with-fpu=vfp"
	    ;;
	esac
	;;
    mips*)
	CONF_ARGS="--with-arch=${DEFAULT_CPU-mips32r2} \
		    --with-float=hard \
		    --enable-mips-nonpic \
		    --enable-extra-sgxxlite-multilibs"
	;;
    *)
	error "Unknown arch"
	;;
    esac
    case "$LIBGCC_STATIC" in
    y|yes|Y|YES)
	CONF_ARGS="$CONF_ARGS --disable-shared"
	;;
    esac
    if [ ! "$GCC_ENABLE_TLS" = "yes" ]; then
	CONF_ARGS="$CONF_ARGS --disable-tls"
    fi
    CONF_ARGS="$CONF_ARGS $GCC_EXTRA_CONF_ARGS"
    echo "configure"
    pushd $TOP_DIR
    mkdir -p "$GCC_DIR/build2"
    cd $GCC_DIR/build2
    ../configure --target=$TARGET_ARCH --prefix=$TOOLCHAIN_PREFIX \
	--exec-prefix=$TOOLCHAIN_PREFIX --with-sysroot=$TOOLCHAIN_SYSROOT \
	--libexecdir=$TOOLCHAIN_PREFIX/lib \
	--enable-threads=posix \
	--enable-languages=c,c++ \
	--enable-c99 \
	--enable-long-long \
	--enable-cmath \
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

    touch "$STATE_DIR/gcc"
}

install_linux_headers

install_uclibc_headers

build_binutils

build_gcc_stage1

build_uClibc

build_gcc

case $TARGET_ARCH in
powerpc*|ppc*)
    . $RULES_DIR/cross-spu.sh
    ;;
esac
