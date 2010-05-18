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

XF86_VIDEO_VIA=xf86-video-via-0.2.2.tar.bz2
XF86_VIDEO_VIA_MIRROR=ftp://ftp.freedesktop.org/pub/xorg/individual/driver
XF86_VIDEO_VIA_DIR=$BUILD_DIR/xf86-video-via-0.2.2
XF86_VIDEO_VIA_ENV="$CROSS_ENV_AC"

build_xf86_video_via() {
    test -e "$STATE_DIR/xf86_video_via.installed" && return
    banner "Build xf86-video-via"
    download $XF86_VIDEO_VIA_MIRROR $XF86_VIDEO_VIA
    extract $XF86_VIDEO_VIA
    apply_patches $XF86_VIDEO_VIA_DIR $XF86_VIDEO_VIA
    pushd $TOP_DIR
    cd $XF86_VIDEO_VIA_DIR
    (
    eval \
	$CROSS_CONF_ENV \
	$XF86_VIDEO_VIA_ENV \
	./configure --build=$BUILD_ARCH --host=$TARGET_ARCH \
	    --prefix=/usr \
	    --sysconfdir=/etc \
	    || error
    ) || error "configure"
    
    make $MAKEARGS || error

    $INSTALL -D -m 644 src/.libs/via_drv.so $ROOTFS_DIR/usr/lib/xorg/modules/drivers/via_drv.so || error
    $STRIP $ROOTFS_DIR/usr/lib/xorg/modules/drivers/via_drv.so

    error "update install"

    popd
    touch "$STATE_DIR/xf86_video_via.installed"
}

build_xf86_video_via
