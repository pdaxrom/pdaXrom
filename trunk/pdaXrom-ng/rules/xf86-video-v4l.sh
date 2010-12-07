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

XF86_VIDEO_V4L_VERSION=0.2.0
XF86_VIDEO_V4L=xf86-video-v4l-${XF86_VIDEO_V4L_VERSION}.tar.bz2
XF86_VIDEO_V4L_MIRROR=ftp://ftp.freedesktop.org/pub/xorg/individual/driver
XF86_VIDEO_V4L_DIR=$BUILD_DIR/xf86-video-v4l-${XF86_VIDEO_V4L_VERSION}
XF86_VIDEO_V4L_ENV="$CROSS_ENV_AC"

build_xf86_video_v4l() {
    test -e "$STATE_DIR/xf86_video_v4l.installed" && return
    banner "Build xf86-video-v4l"
    download $XF86_VIDEO_V4L_MIRROR $XF86_VIDEO_V4L
    extract $XF86_VIDEO_V4L
    apply_patches $XF86_VIDEO_V4L_DIR $XF86_VIDEO_V4L
    pushd $TOP_DIR
    cd $XF86_VIDEO_V4L_DIR
    (
    eval \
	$CROSS_CONF_ENV \
	$XF86_VIDEO_V4L_ENV \
	./configure --build=$BUILD_ARCH --host=$TARGET_ARCH \
	    --prefix=/usr \
	    --sysconfdir=/etc \
	    || error
    ) || error "configure"
    
    make $MAKEARGS || error

    $INSTALL -D -m 644 src/.libs/v4l_drv.so $ROOTFS_DIR/usr/lib/xorg/modules/drivers/v4l_drv.so || error
    $STRIP $ROOTFS_DIR/usr/lib/xorg/modules/drivers/v4l_drv.so

    popd
    touch "$STATE_DIR/xf86_video_v4l.installed"
}

build_xf86_video_v4l
