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

XF86_VIDEO_TSENG=xf86-video-tseng-1.2.1.tar.bz2
XF86_VIDEO_TSENG_MIRROR=ftp://ftp.freedesktop.org/pub/xorg/individual/driver
XF86_VIDEO_TSENG_DIR=$BUILD_DIR/xf86-video-tseng-1.2.1
XF86_VIDEO_TSENG_ENV="$CROSS_ENV_AC"

build_xf86_video_tseng() {
    test -e "$STATE_DIR/xf86_video_tseng.installed" && return
    banner "Build xf86-video-tseng"
    download $XF86_VIDEO_TSENG_MIRROR $XF86_VIDEO_TSENG
    extract $XF86_VIDEO_TSENG
    apply_patches $XF86_VIDEO_TSENG_DIR $XF86_VIDEO_TSENG
    pushd $TOP_DIR
    cd $XF86_VIDEO_TSENG_DIR
    (
    eval \
	$CROSS_CONF_ENV \
	$XF86_VIDEO_TSENG_ENV \
	./configure --build=$BUILD_ARCH --host=$TARGET_ARCH \
	    --prefix=/usr \
	    --sysconfdir=/etc \
	    || error
    ) || error "configure"
    
    make $MAKEARGS || error

    $INSTALL -D -m 644 src/.libs/tseng_drv.so $ROOTFS_DIR/usr/lib/xorg/modules/drivers/tseng_drv.so || error
    $STRIP $ROOTFS_DIR/usr/lib/xorg/modules/drivers/tseng_drv.so

    popd
    touch "$STATE_DIR/xf86_video_tseng.installed"
}

build_xf86_video_tseng
