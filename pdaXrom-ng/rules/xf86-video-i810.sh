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

XF86_VIDEO_I810=xf86-video-i810-1.7.4.tar.bz2
XF86_VIDEO_I810_MIRROR=ftp://ftp.freedesktop.org/pub/xorg/individual/driver
XF86_VIDEO_I810_DIR=$BUILD_DIR/xf86-video-i810-1.7.4
XF86_VIDEO_I810_ENV="$CROSS_ENV_AC"

build_xf86_video_i810() {
    test -e "$STATE_DIR/xf86_video_i810.installed" && return
    banner "Build xf86-video-i810"
    download $XF86_VIDEO_I810_MIRROR $XF86_VIDEO_I810
    extract $XF86_VIDEO_I810
    apply_patches $XF86_VIDEO_I810_DIR $XF86_VIDEO_I810
    pushd $TOP_DIR
    cd $XF86_VIDEO_I810_DIR
    (
    eval \
	$CROSS_CONF_ENV \
	$XF86_VIDEO_I810_ENV \
	./configure --build=$BUILD_ARCH --host=$TARGET_ARCH \
	    --prefix=/usr \
	    --sysconfdir=/etc \
	    || error
    ) || error "configure"
    
    make $MAKEARGS || error

    $INSTALL -D -m 644 src/.libs/i810_drv.so $ROOTFS_DIR/usr/lib/xorg/modules/drivers/i810_drv.so || error
    $STRIP $ROOTFS_DIR/usr/lib/xorg/modules/drivers/i810_drv.so

    error "update install"

    popd
    touch "$STATE_DIR/xf86_video_i810.installed"
}

build_xf86_video_i810
