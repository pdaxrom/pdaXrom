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

XF86_VIDEO_I740_VERSION=1.3.2
XF86_VIDEO_I740=xf86-video-i740-${XF86_VIDEO_I740_VERSION}.tar.bz2
XF86_VIDEO_I740_MIRROR=ftp://ftp.freedesktop.org/pub/xorg/individual/driver
XF86_VIDEO_I740_DIR=$BUILD_DIR/xf86-video-i740-${XF86_VIDEO_I740_VERSION}
XF86_VIDEO_I740_ENV="$CROSS_ENV_AC"

build_xf86_video_i740() {
    test -e "$STATE_DIR/xf86_video_i740.installed" && return
    banner "Build xf86-video-i740"
    download $XF86_VIDEO_I740_MIRROR $XF86_VIDEO_I740
    extract $XF86_VIDEO_I740
    apply_patches $XF86_VIDEO_I740_DIR $XF86_VIDEO_I740
    pushd $TOP_DIR
    cd $XF86_VIDEO_I740_DIR
    (
    eval \
	$CROSS_CONF_ENV \
	$XF86_VIDEO_I740_ENV \
	./configure --build=$BUILD_ARCH --host=$TARGET_ARCH \
	    --prefix=/usr \
	    --sysconfdir=/etc \
	    || error
    ) || error "configure"
    
    make $MAKEARGS || error

    $INSTALL -D -m 644 src/.libs/i740_drv.so $ROOTFS_DIR/usr/lib/xorg/modules/drivers/i740_drv.so || error
    $STRIP $ROOTFS_DIR/usr/lib/xorg/modules/drivers/i740_drv.so

    popd
    touch "$STATE_DIR/xf86_video_i740.installed"
}

build_xf86_video_i740
