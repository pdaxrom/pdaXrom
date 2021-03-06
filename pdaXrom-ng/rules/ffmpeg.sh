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

FFMPEG_VERSION=23467
FFMPEG=ffmpeg-${FFMPEG_VERSION}.tar.bz2
FFMPEG_MIRROR=http://mail.pdaxrom.org/downloads/src
FFMPEG_DIR=$BUILD_DIR/ffmpeg-${FFMPEG_VERSION}
FFMPEG_ENV="$CROSS_ENV_AC"

get_ffmpeg_arch() {
    case $1 in
    i386*|i486*|i586*|i686*)
	echo x86_32
	;;
    x86_64*|amd64*)
	echo x86_64
	;;
    arm*|xscale*)
	echo arm
	;;
    powerpc*)
	echo ppc
	;;
    mips*)
	echo mips
	;;
    *)
	echo $1
	;;
    esac
}

build_ffmpeg() {
    test -e "$STATE_DIR/ffmpeg.installed" && return
    banner "Build ffmpeg"
    download $FFMPEG_MIRROR $FFMPEG
    extract $FFMPEG
    apply_patches $FFMPEG_DIR $FFMPEG
    pushd $TOP_DIR
    cd $FFMPEG_DIR
    (
    local C_ARGS="${FFMPEG_CONFIGURE_OPTS}"
    case $TARGET_ARCH in
    mips*)
	case $TARGET_ARCH in
	mips64*-ls2f-*)
	    C_ARGS="--extra-cflags='-march=loongson2f -mtune=loongson2f'"
	    ;;
	*-ls2f-*)
	    C_ARGS="--extra-cflags='-mtune=loongson2f' --enable-godson2"
	    ;;
	esac
	;;
    esac
    eval \
	$CROSS_CONF_ENV \
	$FFMPEG_ENV \
	./configure \
	    --prefix=/usr \
	    --disable-debug \
	    --enable-shared \
	    --disable-static \
	    --enable-nonfree \
	    --enable-cross-compile \
	    --target-os=linux \
	    --cc=${CROSS}gcc \
	    --as=${CROSS}gcc \
	    --nm=${CROSS}nm \
	    --ld=${CROSS}gcc \
	    --arch=`get_ffmpeg_arch ${TARGET_ARCH}` \
	    --disable-stripping \
	    --enable-libspeex \
	    --enable-libtheora \
	    --enable-libvorbis \
	    --enable-postproc \
	    $C_ARGS \
	    || error
    ) || error "configure"
    
    make $MAKEARGS || error

    install_sysroot_files || error

    ln -s libpostproc ${TARGET_INC}/postproc

    install_fakeroot_init
    install_fakeroot_finish || error

    popd
    touch "$STATE_DIR/ffmpeg.installed"
}

build_ffmpeg
