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

XF86_VIDEO_S3VIRGE=xf86-video-s3virge-1.10.2.tar.bz2
XF86_VIDEO_S3VIRGE_MIRROR=ftp://ftp.freedesktop.org/pub/xorg/individual/driver
XF86_VIDEO_S3VIRGE_DIR=$BUILD_DIR/xf86-video-s3virge-1.10.2
XF86_VIDEO_S3VIRGE_ENV="$CROSS_ENV_AC"

build_xf86_video_s3virge() {
    test -e "$STATE_DIR/xf86_video_s3virge.installed" && return
    banner "Build xf86-video-s3virge"
    download $XF86_VIDEO_S3VIRGE_MIRROR $XF86_VIDEO_S3VIRGE
    extract $XF86_VIDEO_S3VIRGE
    apply_patches $XF86_VIDEO_S3VIRGE_DIR $XF86_VIDEO_S3VIRGE
    pushd $TOP_DIR
    cd $XF86_VIDEO_S3VIRGE_DIR
    (
    eval \
	$CROSS_CONF_ENV \
	$XF86_VIDEO_S3VIRGE_ENV \
	./configure --build=$BUILD_ARCH --host=$TARGET_ARCH \
	    --prefix=/usr \
	    --sysconfdir=/etc \
	    || error
    ) || error "configure"
    
    make $MAKEARGS || error

    $INSTALL -D -m 644 src/.libs/s3virge_drv.so $ROOTFS_DIR/usr/lib/xorg/modules/drivers/s3virge_drv.so || error
    $STRIP $ROOTFS_DIR/usr/lib/xorg/modules/drivers/s3virge_drv.so

    popd
    touch "$STATE_DIR/xf86_video_s3virge.installed"
}

build_xf86_video_s3virge
