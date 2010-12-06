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

XF86_VIDEO_I128=xf86-video-i128-1.3.1.tar.bz2
XF86_VIDEO_I128_MIRROR=ftp://ftp.freedesktop.org/pub/xorg/individual/driver
XF86_VIDEO_I128_DIR=$BUILD_DIR/xf86-video-i128-1.3.1
XF86_VIDEO_I128_ENV="$CROSS_ENV_AC"

build_xf86_video_i128() {
    test -e "$STATE_DIR/xf86_video_i128.installed" && return
    banner "Build xf86-video-i128"
    download $XF86_VIDEO_I128_MIRROR $XF86_VIDEO_I128
    extract $XF86_VIDEO_I128
    apply_patches $XF86_VIDEO_I128_DIR $XF86_VIDEO_I128
    pushd $TOP_DIR
    cd $XF86_VIDEO_I128_DIR
    (
    eval \
	$CROSS_CONF_ENV \
	$XF86_VIDEO_I128_ENV \
	./configure --build=$BUILD_ARCH --host=$TARGET_ARCH \
	    --prefix=/usr \
	    --sysconfdir=/etc \
	    || error
    ) || error "configure"
    
    make $MAKEARGS || error

    $INSTALL -D -m 644 src/.libs/i128_drv.so $ROOTFS_DIR/usr/lib/xorg/modules/drivers/i128_drv.so || error
    $STRIP $ROOTFS_DIR/usr/lib/xorg/modules/drivers/i128_drv.so

    popd
    touch "$STATE_DIR/xf86_video_i128.installed"
}

build_xf86_video_i128
