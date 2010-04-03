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

XF86_VIDEO_CHIPS=xf86-video-chips-1.2.1.tar.bz2
XF86_VIDEO_CHIPS_MIRROR=ftp://ftp.freedesktop.org/pub/xorg/individual/driver
XF86_VIDEO_CHIPS_DIR=$BUILD_DIR/xf86-video-chips-1.2.1
XF86_VIDEO_CHIPS_ENV="$CROSS_ENV_AC"

build_xf86_video_chips() {
    test -e "$STATE_DIR/xf86_video_chips.installed" && return
    banner "Build xf86-video-chips"
    download $XF86_VIDEO_CHIPS_MIRROR $XF86_VIDEO_CHIPS
    extract $XF86_VIDEO_CHIPS
    apply_patches $XF86_VIDEO_CHIPS_DIR $XF86_VIDEO_CHIPS
    pushd $TOP_DIR
    cd $XF86_VIDEO_CHIPS_DIR
    (
    eval \
	$CROSS_CONF_ENV \
	$XF86_VIDEO_CHIPS_ENV \
	./configure --build=$BUILD_ARCH --host=$TARGET_ARCH \
	    --prefix=/usr \
	    --sysconfdir=/etc \
	    || error
    ) || error "configure"
    
    make $MAKEARGS || error

    $INSTALL -D -m 644 src/.libs/chips_drv.so $ROOTFS_DIR/usr/lib/xorg/modules/drivers/chips_drv.so || error
    $STRIP $ROOTFS_DIR/usr/lib/xorg/modules/drivers/chips_drv.so

    popd
    touch "$STATE_DIR/xf86_video_chips.installed"
}

build_xf86_video_chips
