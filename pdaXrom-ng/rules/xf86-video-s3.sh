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

XF86_VIDEO_S3_VERSION=0.6.3
XF86_VIDEO_S3=xf86-video-s3-${XF86_VIDEO_S3_VERSION}.tar.bz2
XF86_VIDEO_S3_MIRROR=ftp://ftp.freedesktop.org/pub/xorg/individual/driver
XF86_VIDEO_S3_DIR=$BUILD_DIR/xf86-video-s3-${XF86_VIDEO_S3_VERSION}
XF86_VIDEO_S3_ENV="$CROSS_ENV_AC"

build_xf86_video_s3() {
    test -e "$STATE_DIR/xf86_video_s3.installed" && return
    banner "Build xf86-video-s3"
    download $XF86_VIDEO_S3_MIRROR $XF86_VIDEO_S3
    extract $XF86_VIDEO_S3
    apply_patches $XF86_VIDEO_S3_DIR $XF86_VIDEO_S3
    pushd $TOP_DIR
    cd $XF86_VIDEO_S3_DIR
    (
    eval \
	$CROSS_CONF_ENV \
	$XF86_VIDEO_S3_ENV \
	./configure --build=$BUILD_ARCH --host=$TARGET_ARCH \
	    --prefix=/usr \
	    --sysconfdir=/etc \
	    || error
    ) || error "configure"
    
    make $MAKEARGS || error

    $INSTALL -D -m 644 src/.libs/s3_drv.so $ROOTFS_DIR/usr/lib/xorg/modules/drivers/s3_drv.so || error
    $STRIP $ROOTFS_DIR/usr/lib/xorg/modules/drivers/s3_drv.so

    popd
    touch "$STATE_DIR/xf86_video_s3.installed"
}

build_xf86_video_s3
