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

XF86_VIDEO_SISUSB=xf86-video-sisusb-0.9.0.tar.bz2
XF86_VIDEO_SISUSB_MIRROR=ftp://ftp.freedesktop.org/pub/xorg/individual/driver
XF86_VIDEO_SISUSB_DIR=$BUILD_DIR/xf86-video-sisusb-0.9.0
XF86_VIDEO_SISUSB_ENV="$CROSS_ENV_AC"

build_xf86_video_sisusb() {
    test -e "$STATE_DIR/xf86_video_sisusb.installed" && return
    banner "Build xf86-video-sisusb"
    download $XF86_VIDEO_SISUSB_MIRROR $XF86_VIDEO_SISUSB
    extract $XF86_VIDEO_SISUSB
    apply_patches $XF86_VIDEO_SISUSB_DIR $XF86_VIDEO_SISUSB
    pushd $TOP_DIR
    cd $XF86_VIDEO_SISUSB_DIR
    (
    eval \
	$CROSS_CONF_ENV \
	$XF86_VIDEO_SISUSB_ENV \
	./configure --build=$BUILD_ARCH --host=$TARGET_ARCH \
	    --prefix=/usr \
	    --sysconfdir=/etc \
	    || error
    ) || error "configure"
    
    make $MAKEARGS || error

    $INSTALL -D -m 644 src/.libs/sisusb_drv.so $ROOTFS_DIR/usr/lib/xorg/modules/drivers/sisusb_drv.so || error
    $STRIP $ROOTFS_DIR/usr/lib/xorg/modules/drivers/sisusb_drv.so

    popd
    touch "$STATE_DIR/xf86_video_sisusb.installed"
}

build_xf86_video_sisusb
