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

GST_FFMPEG_VERSION=0.10.8
GST_FFMPEG=gst-ffmpeg-${GST_FFMPEG_VERSION}.tar.bz2
GST_FFMPEG_MIRROR=http://gstreamer.freedesktop.org/src/gst-ffmpeg
GST_FFMPEG_DIR=$BUILD_DIR/gst-ffmpeg-${GST_FFMPEG_VERSION}
GST_FFMPEG_ENV="$CROSS_ENV_AC"

build_gst_ffmpeg() {
    test -e "$STATE_DIR/gst_ffmpeg.installed" && return
    banner "Build gst-ffmpeg"
    download $GST_FFMPEG_MIRROR $GST_FFMPEG
    extract $GST_FFMPEG
    apply_patches $GST_FFMPEG_DIR $GST_FFMPEG
    pushd $TOP_DIR
    cd $GST_FFMPEG_DIR
    (
    eval \
	$CROSS_CONF_ENV \
	$GST_FFMPEG_ENV \
	./configure --build=$BUILD_ARCH --host=$TARGET_ARCH \
	    --prefix=/usr \
	    --sysconfdir=/etc \
	    --with-system-ffmpeg \
	    || error
    ) || error "configure"

    make $MAKEARGS || error

    install_fakeroot_init
    install_fakeroot_finish || error

    popd
    touch "$STATE_DIR/gst_ffmpeg.installed"
}

build_gst_ffmpeg
