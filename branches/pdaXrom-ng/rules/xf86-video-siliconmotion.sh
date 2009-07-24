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

XF86_VIDEO_SILICONMOTION_VERSION=1.7.2
XF86_VIDEO_SILICONMOTION=xf86-video-siliconmotion-${XF86_VIDEO_SILICONMOTION_VERSION}.tar.bz2
XF86_VIDEO_SILICONMOTION_MIRROR=ftp://ftp.freedesktop.org/pub/xorg/individual/driver
XF86_VIDEO_SILICONMOTION_DIR=$BUILD_DIR/xf86-video-siliconmotion-${XF86_VIDEO_SILICONMOTION_VERSION}
XF86_VIDEO_SILICONMOTION_ENV="$CROSS_ENV_AC"

build_xf86_video_siliconmotion() {
    test -e "$STATE_DIR/xf86_video_siliconmotion.installed" && return
    banner "Build xf86-video-siliconmotion"
    download $XF86_VIDEO_SILICONMOTION_MIRROR $XF86_VIDEO_SILICONMOTION
    extract $XF86_VIDEO_SILICONMOTION
    apply_patches $XF86_VIDEO_SILICONMOTION_DIR $XF86_VIDEO_SILICONMOTION
    pushd $TOP_DIR
    cd $XF86_VIDEO_SILICONMOTION_DIR
    (
    eval \
	$CROSS_CONF_ENV \
	$XF86_VIDEO_SILICONMOTION_ENV \
	./configure --build=$BUILD_ARCH --host=$TARGET_ARCH \
	    --prefix=/usr \
	    --sysconfdir=/etc \
	    || error
    ) || error "configure"
    
    make $MAKEARGS || error

    $INSTALL -D -m 644 src/.libs/siliconmotion_drv.so $ROOTFS_DIR/usr/lib/xorg/modules/drivers/siliconmotion_drv.so || error
    $STRIP $ROOTFS_DIR/usr/lib/xorg/modules/drivers/siliconmotion_drv.so

    popd
    touch "$STATE_DIR/xf86_video_siliconmotion.installed"
}

build_xf86_video_siliconmotion
