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

XF86_VIDEO_NEWPORT=xf86-video-newport-0.2.1.tar.bz2
XF86_VIDEO_NEWPORT_MIRROR=ftp://ftp.freedesktop.org/pub/xorg/individual/driver
XF86_VIDEO_NEWPORT_DIR=$BUILD_DIR/xf86-video-newport-0.2.1
XF86_VIDEO_NEWPORT_ENV="$CROSS_ENV_AC"

build_xf86_video_newport() {
    test -e "$STATE_DIR/xf86_video_newport.installed" && return
    banner "Build xf86-video-newport"
    download $XF86_VIDEO_NEWPORT_MIRROR $XF86_VIDEO_NEWPORT
    extract $XF86_VIDEO_NEWPORT
    apply_patches $XF86_VIDEO_NEWPORT_DIR $XF86_VIDEO_NEWPORT
    pushd $TOP_DIR
    cd $XF86_VIDEO_NEWPORT_DIR
    (
    eval \
	$CROSS_CONF_ENV \
	$XF86_VIDEO_NEWPORT_ENV \
	./configure --build=$BUILD_ARCH --host=$TARGET_ARCH \
	    --prefix=/usr \
	    --sysconfdir=/etc \
	    || error
    ) || error "configure"
    
    make $MAKEARGS || error

    $INSTALL -D -m 644 src/.libs/newport_drv.so $ROOTFS_DIR/usr/lib/xorg/modules/drivers/newport_drv.so || error
    $STRIP $ROOTFS_DIR/usr/lib/xorg/modules/drivers/newport_drv.so

    popd
    touch "$STATE_DIR/xf86_video_newport.installed"
}

build_xf86_video_newport
