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

    make $MAKEARGS all CPU=PPC NO_ASM=1 GUI=GTK2 PREFIX=/usr \
	CC=${CROSS}gcc CXX=${CROSS}g++ \
	AR=${CROSS}ar RANLIB=${CROSS}ranlib \
	LD=${CROSS}g++ STRIP=${CROSS}strip || error

    ./install.sh $ROOTFS_DIR/usr

    popd
    touch "$STATE_DIR/Mupen64Plus.installed"
}

build_Mupen64Plus
