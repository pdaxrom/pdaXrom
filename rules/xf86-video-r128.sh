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

XF86_VIDEO_R128=xf86-video-r128-6.8.0.tar.bz2
XF86_VIDEO_R128_MIRROR=ftp://ftp.freedesktop.org/pub/xorg/individual/driver
XF86_VIDEO_R128_DIR=$BUILD_DIR/xf86-video-r128-6.8.0
XF86_VIDEO_R128_ENV="$CROSS_ENV_AC"

build_xf86_video_r128() {
    test -e "$STATE_DIR/xf86_video_r128.installed" && return
    banner "Build xf86-video-r128"
    download $XF86_VIDEO_R128_MIRROR $XF86_VIDEO_R128
    extract $XF86_VIDEO_R128
    apply_patches $XF86_VIDEO_R128_DIR $XF86_VIDEO_R128
    pushd $TOP_DIR
    cd $XF86_VIDEO_R128_DIR
    (
    eval \
	$CROSS_CONF_ENV \
	$XF86_VIDEO_R128_ENV \
	./configure --build=$BUILD_ARCH --host=$TARGET_ARCH \
	    --prefix=/usr \
	    --sysconfdir=/etc \
	    || error
    ) || error "configure"
    
    make $MAKEARGS || error

    $INSTALL -D -m 644 src/.libs/r128_drv.so $ROOTFS_DIR/usr/lib/xorg/modules/drivers/r128_drv.so || error
    $STRIP $ROOTFS_DIR/usr/lib/xorg/modules/drivers/r128_drv.so

    popd
    touch "$STATE_DIR/xf86_video_r128.installed"
}

build_xf86_video_r128
