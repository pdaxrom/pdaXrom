#
# packet template
#
# Copyright (C) 2008 by Alexander Chukov <sash@pdaXrom.org>
#          
# See CREDITS for details about who has contributed to this project.
#
# For further information about the pdaXrom project and license conditions
# see the README file.
#

XF86_VIDEO_VESA=xf86-video-vesa-2.0.0.tar.bz2
XF86_VIDEO_VESA_MIRROR=ftp://ftp.freedesktop.org/pub/xorg/individual/driver
XF86_VIDEO_VESA_DIR=$BUILD_DIR/xf86-video-vesa-2.0.0
XF86_VIDEO_VESA_ENV=

build_xf86_video_vesa() {
    test -e "$STATE_DIR/xf86_video_vesa-2.0.0" && return
    banner "Build $XF86_VIDEO_VESA"
    download $XF86_VIDEO_VESA_MIRROR $XF86_VIDEO_VESA
    extract $XF86_VIDEO_VESA
    apply_patches $XF86_VIDEO_VESA_DIR $XF86_VIDEO_VESA
    pushd $TOP_DIR
    cd $XF86_VIDEO_VESA_DIR
    (
    eval \
	$CROSS_CONF_ENV \
	$XF86_VIDEO_VESA_ENV \
	./configure --build=$BUILD_ARCH --host=$TARGET_ARCH \
	    --prefix=/usr \
	    --sysconfdir=/etc \
	    || error
    )
    make $MAKEARGS || error

    $INSTALL -D -m 644 src/.libs/vesa_drv.so $ROOTFS_DIR/usr/lib/xorg/modules/drivers/vesa_drv.so || error
    $STRIP $ROOTFS_DIR/usr/lib/xorg/modules/drivers/vesa_drv.so

    popd
    touch "$STATE_DIR/xf86_video_vesa-2.0.0"
}

build_xf86_video_vesa
