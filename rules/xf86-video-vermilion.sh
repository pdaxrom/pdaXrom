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

XF86_VIDEO_VERMILION=xf86-video-vermilion-1.0.1.tar.bz2
XF86_VIDEO_VERMILION_MIRROR=ftp://ftp.freedesktop.org/pub/xorg/individual/driver
XF86_VIDEO_VERMILION_DIR=$BUILD_DIR/xf86-video-vermilion-1.0.1
XF86_VIDEO_VERMILION_ENV="$CROSS_ENV_AC"

build_xf86_video_vermilion() {
    test -e "$STATE_DIR/xf86_video_vermilion.installed" && return
    banner "Build xf86-video-vermilion"
    download $XF86_VIDEO_VERMILION_MIRROR $XF86_VIDEO_VERMILION
    extract $XF86_VIDEO_VERMILION
    apply_patches $XF86_VIDEO_VERMILION_DIR $XF86_VIDEO_VERMILION
    pushd $TOP_DIR
    cd $XF86_VIDEO_VERMILION_DIR
    (
    eval \
	$CROSS_CONF_ENV \
	$XF86_VIDEO_VERMILION_ENV \
	./configure --build=$BUILD_ARCH --host=$TARGET_ARCH \
	    --prefix=/usr \
	    --sysconfdir=/etc \
	    || error
    ) || error "configure"
    
    make $MAKEARGS || error

    $INSTALL -D -m 644 src/.libs/vermilion_drv.so $ROOTFS_DIR/usr/lib/xorg/modules/drivers/vermilion_drv.so || error
    $STRIP $ROOTFS_DIR/usr/lib/xorg/modules/drivers/vermilion_drv.so

    error "update install"

    popd
    touch "$STATE_DIR/xf86_video_vermilion.installed"
}

build_xf86_video_vermilion
