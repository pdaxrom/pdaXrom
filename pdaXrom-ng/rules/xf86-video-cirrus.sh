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

XF86_VIDEO_CIRRUS_VERSION=1.3.2
XF86_VIDEO_CIRRUS=xf86-video-cirrus-${XF86_VIDEO_CIRRUS_VERSION}.tar.bz2
XF86_VIDEO_CIRRUS_MIRROR=ftp://ftp.freedesktop.org/pub/xorg/individual/driver
XF86_VIDEO_CIRRUS_DIR=$BUILD_DIR/xf86-video-cirrus-${XF86_VIDEO_CIRRUS_VERSION}
XF86_VIDEO_CIRRUS_ENV=

build_xf86_video_cirrus() {
    test -e "$STATE_DIR/xf86_video_cirrus-${XF86_VIDEO_CIRRUS_VERSION}" && return
    banner "Build $XF86_VIDEO_CIRRUS"
    download $XF86_VIDEO_CIRRUS_MIRROR $XF86_VIDEO_CIRRUS
    extract $XF86_VIDEO_CIRRUS
    apply_patches $XF86_VIDEO_CIRRUS_DIR $XF86_VIDEO_CIRRUS
    pushd $TOP_DIR
    cd $XF86_VIDEO_CIRRUS_DIR
    (
    eval \
	$CROSS_CONF_ENV \
	$XF86_VIDEO_CIRRUS_ENV \
	./configure --build=$BUILD_ARCH --host=$TARGET_ARCH \
	    --prefix=/usr \
	    --sysconfdir=/etc \
	    || error
    )
    make $MAKEARGS || error

    install_fakeroot_init

    install_fakeroot_finish || error

    #$INSTALL -D -m 644 src/.libs/cirrus_drv.so $ROOTFS_DIR/usr/lib/xorg/modules/drivers/cirrus_drv.so || error
    #$STRIP $ROOTFS_DIR/usr/lib/xorg/modules/drivers/cirrus_drv.so
    #$INSTALL -D -m 644 src/.libs/cirrus_alpine.so $ROOTFS_DIR/usr/lib/xorg/modules/drivers/cirrus_alpine.so || error
    #$STRIP $ROOTFS_DIR/usr/lib/xorg/modules/drivers/cirrus_alpine.so
    #$INSTALL -D -m 644 src/.libs/cirrus_laguna.so $ROOTFS_DIR/usr/lib/xorg/modules/drivers/cirrus_laguna.so || error
    #$STRIP $ROOTFS_DIR/usr/lib/xorg/modules/drivers/cirrus_laguna.so

    popd
    touch "$STATE_DIR/xf86_video_cirrus-${XF86_VIDEO_CIRRUS_VERSION}"
}

build_xf86_video_cirrus
