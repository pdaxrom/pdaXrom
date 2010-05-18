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

XF86_VIDEO_MACH64=xf86-video-mach64-6.8.0.tar.bz2
XF86_VIDEO_MACH64_MIRROR=ftp://ftp.freedesktop.org/pub/xorg/individual/driver
XF86_VIDEO_MACH64_DIR=$BUILD_DIR/xf86-video-mach64-6.8.0
XF86_VIDEO_MACH64_ENV="$CROSS_ENV_AC"

build_xf86_video_mach64() {
    test -e "$STATE_DIR/xf86_video_mach64.installed" && return
    banner "Build xf86-video-mach64"
    download $XF86_VIDEO_MACH64_MIRROR $XF86_VIDEO_MACH64
    extract $XF86_VIDEO_MACH64
    apply_patches $XF86_VIDEO_MACH64_DIR $XF86_VIDEO_MACH64
    pushd $TOP_DIR
    cd $XF86_VIDEO_MACH64_DIR
    (
    eval \
	$CROSS_CONF_ENV \
	$XF86_VIDEO_MACH64_ENV \
	./configure --build=$BUILD_ARCH --host=$TARGET_ARCH \
	    --prefix=/usr \
	    --sysconfdir=/etc \
	    || error
    ) || error "configure"
    
    make $MAKEARGS || error

    $INSTALL -D -m 644 src/.libs/mach64_drv.so $ROOTFS_DIR/usr/lib/xorg/modules/drivers/mach64_drv.so || error
    $STRIP $ROOTFS_DIR/usr/lib/xorg/modules/drivers/mach64_drv.so

    popd
    touch "$STATE_DIR/xf86_video_mach64.installed"
}

build_xf86_video_mach64
