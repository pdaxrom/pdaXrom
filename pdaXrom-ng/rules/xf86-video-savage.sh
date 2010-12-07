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

XF86_VIDEO_SAVAGE_VERSION=2.3.2
XF86_VIDEO_SAVAGE=xf86-video-savage-${XF86_VIDEO_SAVAGE_VERSION}.tar.bz2
XF86_VIDEO_SAVAGE_MIRROR=ftp://ftp.freedesktop.org/pub/xorg/individual/driver
XF86_VIDEO_SAVAGE_DIR=$BUILD_DIR/xf86-video-savage-${XF86_VIDEO_SAVAGE_VERSION}
XF86_VIDEO_SAVAGE_ENV="$CROSS_ENV_AC"

build_xf86_video_savage() {
    test -e "$STATE_DIR/xf86_video_savage.installed" && return
    banner "Build xf86-video-savage"
    download $XF86_VIDEO_SAVAGE_MIRROR $XF86_VIDEO_SAVAGE
    extract $XF86_VIDEO_SAVAGE
    apply_patches $XF86_VIDEO_SAVAGE_DIR $XF86_VIDEO_SAVAGE
    pushd $TOP_DIR
    cd $XF86_VIDEO_SAVAGE_DIR
    (
    eval \
	$CROSS_CONF_ENV \
	$XF86_VIDEO_SAVAGE_ENV \
	./configure --build=$BUILD_ARCH --host=$TARGET_ARCH \
	    --prefix=/usr \
	    --sysconfdir=/etc \
	    || error
    ) || error "configure"
    
    make $MAKEARGS || error

    $INSTALL -D -m 644 src/.libs/savage_drv.so $ROOTFS_DIR/usr/lib/xorg/modules/drivers/savage_drv.so || error
    $STRIP $ROOTFS_DIR/usr/lib/xorg/modules/drivers/savage_drv.so

    popd
    touch "$STATE_DIR/xf86_video_savage.installed"
}

build_xf86_video_savage
