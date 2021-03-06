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

MPLAYER_VERSION=29544
MPLAYER=mplayer-${MPLAYER_VERSION}.tar.bz2
MPLAYER_MIRROR=http://mail.pdaXrom.org/downloads/src
MPLAYER_DIR=$BUILD_DIR/mplayer-${MPLAYER_VERSION}
MPLAYER_ENV="$CROSS_ENV_AC"

build_mplayer() {
    test -e "$STATE_DIR/mplayer.installed" && return
    banner "Build mplayer"
    download $MPLAYER_MIRROR $MPLAYER
    extract $MPLAYER
    apply_patches $MPLAYER_DIR $MPLAYER

    local C_ARGS=
    local T_ARCH=
    case $TARGET_ARCH in
    mips*)
	T_ARCH=mips-linux
	case $TARGET_ARCH in
	mips64*-ls2f-*)
	    C_ARGS="--extra-cflags='-march=loongson2f -mtune=loongson2f' --enable-godson2"
	    ;;
	*-ls2f-*)
	    C_ARGS="--extra-cflags='-mtune=loongson2f' --enable-godson2"
	    ;;
	esac
	;;
    arm*)
	T_ARCH=arm-linux
	;;
    ppc*|powerpc*)
	T_ARCH=$TARGET_ARCH
	C_ARGS="--enable-altivec --enable-big-endian"
	;;
    *)
	T_ARCH=$TARGET_ARCH
	;;
    esac

    pushd $TOP_DIR
    cd $MPLAYER_DIR
    (
    eval \
	$CROSS_CONF_ENV \
	$MPLAYER_ENV \
	./configure \
	    --prefix=/usr \
	    --confdir=/etc/mplayer \
	    --disable-mencoder \
	    --disable-ossaudio \
	    --disable-arts \
	    --disable-esd \
	    --disable-pulse \
	    --disable-jack \
	    --disable-openal \
	    --disable-nas \
	    --disable-sgiaudio \
	    --disable-sunaudio \
	    --disable-dart \
	    --disable-win32waveout \
	    --enable-tv \
	    --enable-tv-v4l2 \
	    --enable-tv-v4l1 \
	    --enable-cross-compile \
	    --cc=${CROSS}gcc \
	    --host-cc=gcc \
	    --as=${CROSS}as \
	    --nm=${CROSS}nm \
	    --ar=${CROSS}ar \
	    --ranlib=${CROSS}ranlib \
	    --target=$T_ARCH \
	    --enable-gui \
	    $C_ARGS \
	    || error
    ) || error "configure"
    
    make $MAKEARGS || error

    make DESTDIR=$ROOTFS_DIR install-gui INSTALLSTRIP= || error
    $STRIP $ROOTFS_DIR/usr/bin/mplayer || error

    popd
    touch "$STATE_DIR/mplayer.installed"
}

build_mplayer
