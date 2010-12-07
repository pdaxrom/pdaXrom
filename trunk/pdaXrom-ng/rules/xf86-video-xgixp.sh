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

XF86_VIDEO_XGIXP_VERSION=1.8.0
XF86_VIDEO_XGIXP=xf86-video-xgixp-${XF86_VIDEO_XGIXP_VERSION}.tar.bz2
XF86_VIDEO_XGIXP_MIRROR=ftp://ftp.freedesktop.org/pub/xorg/individual/driver
XF86_VIDEO_XGIXP_DIR=$BUILD_DIR/xf86-video-xgixp-${XF86_VIDEO_XGIXP_VERSION}
XF86_VIDEO_XGIXP_ENV="$CROSS_ENV_AC"

build_xf86_video_xgixp() {
    test -e "$STATE_DIR/xf86_video_xgixp.installed" && return
    banner "Build xf86-video-xgixp"
    download $XF86_VIDEO_XGIXP_MIRROR $XF86_VIDEO_XGIXP
    extract $XF86_VIDEO_XGIXP
    apply_patches $XF86_VIDEO_XGIXP_DIR $XF86_VIDEO_XGIXP
    pushd $TOP_DIR
    cd $XF86_VIDEO_XGIXP_DIR
    (
    eval \
	$CROSS_CONF_ENV \
	$XF86_VIDEO_XGIXP_ENV \
	./configure --build=$BUILD_ARCH --host=$TARGET_ARCH \
	    --prefix=/usr \
	    --sysconfdir=/etc \
	    || error
    ) || error "configure"
    
    make $MAKEARGS || error

    $INSTALL -D -m 644 src/.libs/xgixp_drv.so $ROOTFS_DIR/usr/lib/xorg/modules/drivers/xgixp_drv.so || error
    $STRIP $ROOTFS_DIR/usr/lib/xorg/modules/drivers/xgixp_drv.so

    error "update install"

    popd
    touch "$STATE_DIR/xf86_video_xgixp.installed"
}

build_xf86_video_xgixp
