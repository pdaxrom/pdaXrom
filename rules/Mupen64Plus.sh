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

MUPEN64PLUS_VERSION=1-5
MUPEN64PLUS=Mupen64Plus-${MUPEN64PLUS_VERSION}-src.tar.gz
MUPEN64PLUS_MIRROR=http://mupen64plus.googlecode.com/files
MUPEN64PLUS_DIR=$BUILD_DIR/Mupen64Plus-${MUPEN64PLUS_VERSION}-src
MUPEN64PLUS_ENV="$CROSS_ENV_AC"

build_Mupen64Plus() {
    test -e "$STATE_DIR/Mupen64Plus.installed" && return
    banner "Build Mupen64Plus"
    download $MUPEN64PLUS_MIRROR $MUPEN64PLUS
    extract $MUPEN64PLUS
    apply_patches $MUPEN64PLUS_DIR $MUPEN64PLUS
    pushd $TOP_DIR
    cd $MUPEN64PLUS_DIR

    make -C blight_input ttftoh
    make -C glide64 compiletex

    local C_ARGS=
    case $TARGET_ARCH in
    powerpc-*|ppc-*)
	C_ARGS="CPU=PPC NO_ASM=1 ARCH=32BITS"
	;;
    powerpc64-*|ppc64-*)
	C_ARGS="CPU=PPC NO_ASM=1 ARCH=64BITS"
	;;
    mipsel-*)
	C_ARGS="CPU=mipsel NO_ASM=1 ARCH=32BITS"
	;;
    mips64el-*)
	C_ARGS="CPU=mipsel NO_ASM=1 ARCH=64BITS"
	;;
    arm*)
	C_ARGS="CPU=arm NO_ASM=1 ARCH=32BITS"
	;;
    i*86-*)
	C_ARGS="CPU=X86 ARCH=32BITS"
	;;
    x86_64-*|amd64-*)
	C_ARGS="CPU=X86 ARCH=64BITS"
	;;
    esac

    make $MAKEARGS all $C_ARGS GUI=GTK2 PREFIX=/usr \
	CC=${CROSS}gcc CXX=${CROSS}g++ \
	AR=${CROSS}ar RANLIB=${CROSS}ranlib \
	LD=${CROSS}g++ STRIP=${CROSS}strip || error

    ./install.sh $ROOTFS_DIR/usr

    popd
    touch "$STATE_DIR/Mupen64Plus.installed"
}

build_Mupen64Plus
