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

XF86_VIDEO_NV=xf86-video-nv-2.1.12.tar.bz2
XF86_VIDEO_NV_MIRROR=ftp://ftp.freedesktop.org/pub/xorg/individual/driver
XF86_VIDEO_NV_DIR=$BUILD_DIR/xf86-video-nv-2.1.12
XF86_VIDEO_NV_ENV="$CROSS_ENV_AC"

build_xf86_video_nv() {
    test -e "$STATE_DIR/xf86_video_nv.installed" && return
    banner "Build xf86-video-nv"
    download $XF86_VIDEO_NV_MIRROR $XF86_VIDEO_NV
    extract $XF86_VIDEO_NV
    apply_patches $XF86_VIDEO_NV_DIR $XF86_VIDEO_NV
    pushd $TOP_DIR
    cd $XF86_VIDEO_NV_DIR
    (
    eval \
	$CROSS_CONF_ENV \
	$XF86_VIDEO_NV_ENV \
	./configure --build=$BUILD_ARCH --host=$TARGET_ARCH \
	    --prefix=/usr \
	    --sysconfdir=/etc \
	    || error
    ) || error "configure"
    
    make $MAKEARGS || error

    $INSTALL -D -m 644 src/.libs/nv_drv.so $ROOTFS_DIR/usr/lib/xorg/modules/drivers/nv_drv.so || error
    $STRIP $ROOTFS_DIR/usr/lib/xorg/modules/drivers/nv_drv.so

    popd
    touch "$STATE_DIR/xf86_video_nv.installed"
}

build_xf86_video_nv
