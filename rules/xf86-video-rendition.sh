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

XF86_VIDEO_RENDITION=xf86-video-rendition-4.2.0.tar.bz2
XF86_VIDEO_RENDITION_MIRROR=ftp://ftp.freedesktop.org/pub/xorg/individual/driver
XF86_VIDEO_RENDITION_DIR=$BUILD_DIR/xf86-video-rendition-4.2.0
XF86_VIDEO_RENDITION_ENV="$CROSS_ENV_AC"

build_xf86_video_rendition() {
    test -e "$STATE_DIR/xf86_video_rendition.installed" && return
    banner "Build xf86-video-rendition"
    download $XF86_VIDEO_RENDITION_MIRROR $XF86_VIDEO_RENDITION
    extract $XF86_VIDEO_RENDITION
    apply_patches $XF86_VIDEO_RENDITION_DIR $XF86_VIDEO_RENDITION
    pushd $TOP_DIR
    cd $XF86_VIDEO_RENDITION_DIR
    (
    eval \
	$CROSS_CONF_ENV \
	$XF86_VIDEO_RENDITION_ENV \
	./configure --build=$BUILD_ARCH --host=$TARGET_ARCH \
	    --prefix=/usr \
	    --sysconfdir=/etc \
	    || error
    ) || error "configure"
    
    make $MAKEARGS || error

    $INSTALL -D -m 644 src/.libs/rendition_drv.so $ROOTFS_DIR/usr/lib/xorg/modules/drivers/rendition_drv.so || error
    $STRIP $ROOTFS_DIR/usr/lib/xorg/modules/drivers/rendition_drv.so

    popd
    touch "$STATE_DIR/xf86_video_rendition.installed"
}

build_xf86_video_rendition
