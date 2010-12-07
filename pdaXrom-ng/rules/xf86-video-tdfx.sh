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

XF86_VIDEO_TDFX_VERSION=1.4.3
XF86_VIDEO_TDFX=xf86-video-tdfx-${XF86_VIDEO_TDFX_VERSION}.tar.bz2
XF86_VIDEO_TDFX_MIRROR=ftp://ftp.freedesktop.org/pub/xorg/individual/driver
XF86_VIDEO_TDFX_DIR=$BUILD_DIR/xf86-video-tdfx-${XF86_VIDEO_TDFX_VERSION}
XF86_VIDEO_TDFX_ENV="$CROSS_ENV_AC"

build_xf86_video_tdfx() {
    test -e "$STATE_DIR/xf86_video_tdfx.installed" && return
    banner "Build xf86-video-tdfx"
    download $XF86_VIDEO_TDFX_MIRROR $XF86_VIDEO_TDFX
    extract $XF86_VIDEO_TDFX
    apply_patches $XF86_VIDEO_TDFX_DIR $XF86_VIDEO_TDFX
    pushd $TOP_DIR
    cd $XF86_VIDEO_TDFX_DIR
    (
    eval \
	$CROSS_CONF_ENV \
	$XF86_VIDEO_TDFX_ENV \
	./configure --build=$BUILD_ARCH --host=$TARGET_ARCH \
	    --prefix=/usr \
	    --sysconfdir=/etc \
	    || error
    ) || error "configure"
    
    make $MAKEARGS || error

    $INSTALL -D -m 644 src/.libs/tdfx_drv.so $ROOTFS_DIR/usr/lib/xorg/modules/drivers/tdfx_drv.so || error
    $STRIP $ROOTFS_DIR/usr/lib/xorg/modules/drivers/tdfx_drv.so

    popd
    touch "$STATE_DIR/xf86_video_tdfx.installed"
}

build_xf86_video_tdfx
