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

TARGET_GCC_VERSION=${TARGET_GCC_VERSION-4.4.1}
TARGET_GCC=gcc-${TARGET_GCC_VERSION}.tar.bz2
TARGET_GCC_MIRROR=ftp://gcc.gnu.org/pub/gcc/releases/gcc-${TARGET_GCC_VERSION}
TARGET_GCC_DIR=$BUILD_DIR/gcc-${TARGET_GCC_VERSION}
TARGET_GCC_ENV="$CROSS_ENV_AC"

build_target_gcc() {
    test -e "$STATE_DIR/target_gcc.installed" && return
    banner "Build target_gcc"
    download $TARGET_GCC_MIRROR $TARGET_GCC
    extract $TARGET_GCC
    apply_patches $TARGET_GCC_DIR $TARGET_GCC
    pushd $TOP_DIR
    cd $TARGET_GCC_DIR

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
    mips64*)
	CONF_ARGS="$CONF_ARGS --with-abi=${DEFAULT_MABI-n32}"
	if [ ! "x$DEFAULT_CPU" = "x" ]; then
	    CONF_ARGS="$CONF_ARGS --with-arch=$DEFAULT_CPU"
	fi
	if [ ! "x$DEFAULT_FPU" = "x" ]; then
	    CONF_ARGS="$CONF_ARGS --with-float=$DEFAULT_FPU"
	fi
	CONF_ARGS="$CONF_ARGS --with-mips-plt"
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
	;;
    *)
	error "Unknown arch"
	;;
    esac

    mkdir -p build-target
    cd build-target
    ../configure --build=$BUILD_ARCH \
	--host=$TARGET_ARCH \
	--target=$TARGET_ARCH \
	--prefix=/usr \
	--libexecdir=/usr/lib \
	--enable-linux-futex \
	--enable-threads \
	--enable-shared \
	--enable-languages=c,c++ \
	--enable-c99 \
	--enable-long-long \
	--enable-cmath \
	--disable-libssp \
	--disable-libmudflap \
	--disable-libgomp \
	--disable-multilib \
	--disable-nls \
	--disable-werror \
	--with-gnu-as \
	--with-gnu-ld \
	--with-system-zlib \
	--disable-libstdcxx-pch \
	--enable-__cxa_atexit \
	--with-gmp=$TARGET_BIN_DIR \
	--with-mpfr=$TARGET_BIN_DIR \
	$CONF_ARGS \
	--disable-bootstrap || error "configure"
    make $MAKEARGS MAKEINFO=true || error "make"
    make MAKEINFO=true DESTDIR=${TARGET_GCC_DIR}/build-target/fakeroot install || error "make install"

    rm -rf fakeroot/info fakeroot/man fakeroot/share

    ln -sf g++ fakeroot/usr/bin/c++
    #ln -sf g++ fakeroot/usr/bin/${TARGET_ARCH}-g++
    #ln -sf g++ fakeroot/usr/bin/${TARGET_ARCH}-c++
    ln -sf gcc fakeroot/usr/bin/cc
    #ln -sf gcc fakeroot/usr/bin/${TARGET_ARCH}-gcc
    #ln -sf gcc fakeroot/usr/bin/${TARGET_ARCH}-cc
    #ln -sf gcc fakeroot/usr/bin/${TARGET_ARCH}-gcc-${TARGET_GCC_VERSION}
    #ln -sf gcc fakeroot/usr/bin/${TARGET_ARCH}-gcc-${TARGET_GCC_VERSION}
    rm -rf fakeroot/usr/bin/${TARGET_ARCH}-c++
    rm -rf fakeroot/usr/bin/${TARGET_ARCH}-g++
    rm -rf fakeroot/usr/bin/${TARGET_ARCH}-gcc
    rm -rf fakeroot/usr/bin/${TARGET_ARCH}-gcc-${TARGET_GCC_VERSION}
    ln -sf gcc fakeroot/usr/bin/gcc-${TARGET_GCC_VERSION}
    ln -sf g++ fakeroot/usr/bin/g++-${TARGET_GCC_VERSION}

    $STRIP fakeroot/usr/bin/*
    for f in lib lib32 lib64; do
	test -d fakeroot/usr/$f || continue
	rm -f fakeroot/usr/$f/*.la
	rm -f fakeroot/usr/$f/libgcc*
	rm -f fakeroot/usr/$f/libstdc++*
	rm -f fakeroot/usr/$f/libsupc++*
	rm -f fakeroot/usr/$f/libiberty*
	$STRIP fakeroot/usr/$f/*
    done

    $STRIP fakeroot/usr/lib/gcc/${TARGET_ARCH}/${TARGET_GCC_VERSION}/cc1
    $STRIP fakeroot/usr/lib/gcc/${TARGET_ARCH}/${TARGET_GCC_VERSION}/cc1plus
    $STRIP fakeroot/usr/lib/gcc/${TARGET_ARCH}/${TARGET_GCC_VERSION}/collect2

    cp -a $TOOLCHAIN_SYSROOT/usr/include/* fakeroot/usr/include/
    cp -a $TOOLCHAIN_SYSROOT/usr/lib/*     fakeroot/usr/lib/

    rm -rf fakeroot/usr/man
    rm -rf fakeroot/usr/info

    # install zlib headers
    cp -f $TARGET_INC/zconf.h fakeroot/usr/include/
    cp -f $TARGET_INC/zlib.h  fakeroot/usr/include/
    # install ncurses headers
    make -C ${NCURSES_DIR}/include DESTDIR=${TARGET_GCC_DIR}/build-target/fakeroot install

    install_fakeroot_finish || error

    popd
    touch "$STATE_DIR/target_gcc.installed"
}

build_target_gcc
