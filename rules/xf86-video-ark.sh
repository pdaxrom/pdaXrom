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

XF86_VIDEO_ARK=xf86-video-ark-0.7.1.tar.bz2
XF86_VIDEO_ARK_MIRROR=ftp://ftp.freedesktop.org/pub/xorg/individual/driver
XF86_VIDEO_ARK_DIR=$BUILD_DIR/xf86-video-ark-0.7.1
XF86_VIDEO_ARK_ENV="$CROSS_ENV_AC"

build_xf86_video_ark() {
    test -e "$STATE_DIR/xf86_video_ark.installed" && return
    banner "Build xf86-video-ark"
    download $XF86_VIDEO_ARK_MIRROR $XF86_VIDEO_ARK
    extract $XF86_VIDEO_ARK
    apply_patches $XF86_VIDEO_ARK_DIR $XF86_VIDEO_ARK
    pushd $TOP_DIR
    cd $XF86_VIDEO_ARK_DIR
    (
    eval \
	$CROSS_CONF_ENV \
	$XF86_VIDEO_ARK_ENV \
	./configure --build=$BUILD_ARCH --host=$TARGET_ARCH \
	    --prefix=/usr \
	    --sysconfdir=/etc \
	    || error
    ) || error "configure"
    
    make $MAKEARGS || error

    $INSTALL -D -m 644 src/.libs/ark_drv.so $ROOTFS_DIR/usr/lib/xorg/modules/drivers/ark_drv.so || error
    $STRIP $ROOTFS_DIR/usr/lib/xorg/modules/drivers/ark_drv.so

    popd
    touch "$STATE_DIR/xf86_video_ark.installed"
}

build_xf86_video_ark
