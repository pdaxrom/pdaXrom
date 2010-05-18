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

MESALIB_VERSION_MAJOR=7
MESALIB_VERSION_MINOR=6
MESALIB_VERSION=${MESALIB_VERSION_MAJOR}.${MESALIB_VERSION_MINOR}
MESALIB=MesaLib-${MESALIB_VERSION}.tar.bz2
MESALIB_GLUT=MesaGLUT-${MESALIB_VERSION}.tar.bz2
MESALIB_DEMOS=MesaDemos-${MESALIB_VERSION}.tar.bz2
MESALIB_MIRROR=ftp://ftp.freedesktop.org/pub/mesa/7.6
MESALIB_DIR=$BUILD_DIR/Mesa-${MESALIB_VERSION}
MESALIB_ENV="$CROSS_ENV_AC MKLIB_OPTIONS='-arch Linux'"

build_MesaLib_thud() {
    case $TARGET_ARCH in
    arm*|xscale*)
	echo "linux"
	;;
    mips*)
	echo "linux"
	;;
    ppc64-ps3-*|powerpc64-ps3-*)
	echo "linux-ppc"
	;;
    ppc*-ps3-*|powerpc*-ps3-*)
	if [ -e $TOOLCHAIN_SYSROOT/usr/spu/lib/libmisc.a ]; then
	    echo "linux-cell"
	else
	    echo "linux-ppc"
	fi
	;;
    ppc*|powerpc*)
	echo "linux-dri-ppc"
	;;
    i*86*)
	echo "linux-dri-x86"
	;;
    x86_64*|amd64*)
	echo "linux-dri-x86-64"
	;;
    *)
	echo "linux-dri"
	;;
    esac
}

build_MesaLib() {
    test -e "$STATE_DIR/MesaLib.installed" && return
    banner "Build MesaLib"
    download $MESALIB_MIRROR $MESALIB
    download $MESALIB_MIRROR $MESALIB_GLUT
    download $MESALIB_MIRROR $MESALIB_DEMOS
    extract $MESALIB
    extract $MESALIB_GLUT
    extract $MESALIB_DEMOS
    apply_patches $MESALIB_DIR $MESALIB
    pushd $TOP_DIR
    cd $MESALIB_DIR

    make $MAKEARGS `build_MesaLib_thud` CROSS=${CROSS} \
	CC=${CROSS}gcc \
	CXX=${CROSS}g++ \
	APP_CC=${CROSS}gcc \
	APP_CXX=${CROSS}g++ \
	SPU_AR=${CROSS}ar \
	SPU_EMBED=${CROSS}embedspu \
	SDK=${TOOLCHAIN_SYSROOT}/usr \
	MKDEP=true \
	X11_INCLUDES="-I$TARGET_INC" \
	EXTRA_LIB_PATH="-Wl,-rpath,$TARGET_LIB -L$TARGET_LIB" \
	INSTALL_DIR="/usr" \
	APP_LIB_DEPS="-Wl,-rpath,$TARGET_LIB -L$TARGET_LIB" \
	|| error

    install_sysroot_files CROSS=${CROSS} \
	CC=${CROSS}gcc \
	CXX=${CROSS}g++ \
	APP_CC=${CROSS}gcc \
	APP_CXX=${CROSS}g++ \
	SPU_AR=${CROSS}ar \
	SPU_EMBED=${CROSS}embedspu \
	SDK=${TOOLCHAIN_SYSROOT}/usr \
	MKDEP=true \
	X11_INCLUDES="-I$TARGET_INC" \
	EXTRA_LIB_PATH="-L$TARGET_LIB" \
	INSTALL_DIR="/usr" \
	|| error

    if [ ! -e src/mesa/gl.pc ]; then
	make -C src/mesa gl.pc INSTALL_DIR=$TARGET_BIN_DIR || error
	$INSTALL -D -m 644 src/mesa/gl.pc $TARGET_LIB/pkgconfig/gl.pc || error
    fi

    make $MAKEARGS CROSS=${CROSS} \
	CC=${CROSS}gcc \
	CXX=${CROSS}g++ \
	APP_CC=${CROSS}gcc \
	APP_CXX=${CROSS}g++ \
	SPU_AR=${CROSS}ar \
	SPU_EMBED=${CROSS}embedspu \
	SDK=${TOOLCHAIN_SYSROOT}/usr \
	MKDEP=true \
	X11_INCLUDES="-I$TARGET_INC" \
	EXTRA_LIB_PATH="-L$TARGET_LIB" \
	INSTALL_DIR="/usr" \
	DESTDIR=$MESALIB_DIR/fakeroot \
	install \
	|| error

    rm -rf fakeroot/usr/include fakeroot/usr/lib/pkgconfig fakeroot/usr/lib64/pkgconfig

    test -f progs/xdemos/glxgears && $INSTALL -D -m 755 progs/xdemos/glxgears fakeroot/usr/bin/glxgears
    test -f progs/xdemos/glxinfo  && $INSTALL -D -m 755 progs/xdemos/glxinfo  fakeroot/usr/bin/glxinfo

    find fakeroot -not -type d | while read f; do
	file $f | grep -q "ELF " && $STRIP $f
    done

    install_fakeroot_finish || error

    popd
    touch "$STATE_DIR/MesaLib.installed"
}

build_MesaLib
