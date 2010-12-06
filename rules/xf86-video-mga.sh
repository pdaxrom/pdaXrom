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

XF86_VIDEO_MGA=xf86-video-mga-1.4.9.tar.bz2
XF86_VIDEO_MGA_MIRROR=ftp://ftp.freedesktop.org/pub/xorg/individual/driver
XF86_VIDEO_MGA_DIR=$BUILD_DIR/xf86-video-mga-1.4.9
XF86_VIDEO_MGA_ENV="$CROSS_ENV_AC"

build_xf86_video_mga() {
    test -e "$STATE_DIR/xf86_video_mga.installed" && return
    banner "Build xf86-video-mga"
    download $XF86_VIDEO_MGA_MIRROR $XF86_VIDEO_MGA
    extract $XF86_VIDEO_MGA
    apply_patches $XF86_VIDEO_MGA_DIR $XF86_VIDEO_MGA
    pushd $TOP_DIR
    cd $XF86_VIDEO_MGA_DIR
    (
    eval \
	$CROSS_CONF_ENV \
	$XF86_VIDEO_MGA_ENV \
	./configure --build=$BUILD_ARCH --host=$TARGET_ARCH \
	    --prefix=/usr \
	    --sysconfdir=/etc \
	    || error
    ) || error "configure"
    
    make $MAKEARGS || error

    $INSTALL -D -m 644 src/.libs/mga_drv.so $ROOTFS_DIR/usr/lib/xorg/modules/drivers/mga_drv.so || error
    $STRIP $ROOTFS_DIR/usr/lib/xorg/modules/drivers/mga_drv.so

    popd
    touch "$STATE_DIR/xf86_video_mga.installed"
}

build_xf86_video_mga
