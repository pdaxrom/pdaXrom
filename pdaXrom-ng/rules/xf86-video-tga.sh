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

XF86_VIDEO_TGA_VERSION=1.2.1
XF86_VIDEO_TGA=xf86-video-tga-${XF86_VIDEO_TGA_VERSION}.tar.bz2
XF86_VIDEO_TGA_MIRROR=ftp://ftp.freedesktop.org/pub/xorg/individual/driver
XF86_VIDEO_TGA_DIR=$BUILD_DIR/xf86-video-tga-${XF86_VIDEO_TGA_VERSION}
XF86_VIDEO_TGA_ENV="$CROSS_ENV_AC"

build_xf86_video_tga() {
    test -e "$STATE_DIR/xf86_video_tga.installed" && return
    banner "Build xf86-video-tga"
    download $XF86_VIDEO_TGA_MIRROR $XF86_VIDEO_TGA
    extract $XF86_VIDEO_TGA
    apply_patches $XF86_VIDEO_TGA_DIR $XF86_VIDEO_TGA
    pushd $TOP_DIR
    cd $XF86_VIDEO_TGA_DIR
    (
    eval \
	$CROSS_CONF_ENV \
	$XF86_VIDEO_TGA_ENV \
	./configure --build=$BUILD_ARCH --host=$TARGET_ARCH \
	    --prefix=/usr \
	    --sysconfdir=/etc \
	    || error
    ) || error "configure"
    
    make $MAKEARGS || error

    $INSTALL -D -m 644 src/.libs/tga_drv.so $ROOTFS_DIR/usr/lib/xorg/modules/drivers/tga_drv.so || error
    $STRIP $ROOTFS_DIR/usr/lib/xorg/modules/drivers/tga_drv.so

    popd
    touch "$STATE_DIR/xf86_video_tga.installed"
}

build_xf86_video_tga
