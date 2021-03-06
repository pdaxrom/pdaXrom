#
# packet template
#
# Copyright (C) 2008 by Alexander Chukov <sash@pdaXrom.org>
#          
# See CREDITS for details about who has contributed to this project.
#
# For further information about the pdaXrom project and license conditions
# see the README file.
#

XF86_VIDEO_FBDEV_VERSION=0.4.2
XF86_VIDEO_FBDEV=xf86-video-fbdev-${XF86_VIDEO_FBDEV_VERSION}.tar.bz2
XF86_VIDEO_FBDEV_MIRROR=ftp://ftp.freedesktop.org/pub/xorg/individual/driver
XF86_VIDEO_FBDEV_DIR=$BUILD_DIR/xf86-video-fbdev-${XF86_VIDEO_FBDEV_VERSION}
XF86_VIDEO_FBDEV_ENV=

build_xf86_video_fbdev() {
    test -e "$STATE_DIR/xf86_video_fbdev-${XF86_VIDEO_FBDEV_VERSION}" && return
    banner "Build $XF86_VIDEO_FBDEV"
    download $XF86_VIDEO_FBDEV_MIRROR $XF86_VIDEO_FBDEV
    extract $XF86_VIDEO_FBDEV
    apply_patches $XF86_VIDEO_FBDEV_DIR $XF86_VIDEO_FBDEV
    pushd $TOP_DIR
    cd $XF86_VIDEO_FBDEV_DIR
    (
    eval \
	$CROSS_CONF_ENV \
	$XF86_VIDEO_FBDEV_ENV \
	./configure --build=$BUILD_ARCH --host=$TARGET_ARCH \
	    --prefix=/usr \
	    --sysconfdir=/etc \
	    || error
    )
    make $MAKEARGS || error

    install_fakeroot_init

    install_fakeroot_finish || error

    #$INSTALL -D -m 644 src/.libs/fbdev_drv.so $ROOTFS_DIR/usr/lib/xorg/modules/drivers/fbdev_drv.so || error
    #$STRIP $ROOTFS_DIR/usr/lib/xorg/modules/drivers/fbdev_drv.so

    popd
    touch "$STATE_DIR/xf86_video_fbdev-${XF86_VIDEO_FBDEV_VERSION}"
}

build_xf86_video_fbdev
