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

XF86_VIDEO_GEODE_VERSION=2.11.10
XF86_VIDEO_GEODE=xf86-video-geode-${XF86_VIDEO_GEODE_VERSION}.tar.bz2
XF86_VIDEO_GEODE_MIRROR=ftp://ftp.freedesktop.org/pub/xorg/individual/driver
XF86_VIDEO_GEODE_DIR=$BUILD_DIR/xf86-video-geode-${XF86_VIDEO_GEODE_VERSION}
XF86_VIDEO_GEODE_ENV="$CROSS_ENV_AC"

build_xf86_video_geode() {
    test -e "$STATE_DIR/xf86_video_geode-${XF86_VIDEO_GEODE_VERSION}.installed" && return
    banner "Build xf86-video-geode"
    download $XF86_VIDEO_GEODE_MIRROR $XF86_VIDEO_GEODE
    extract $XF86_VIDEO_GEODE
    apply_patches $XF86_VIDEO_GEODE_DIR $XF86_VIDEO_GEODE
    pushd $TOP_DIR
    cd $XF86_VIDEO_GEODE_DIR
    (
    eval \
	$CROSS_CONF_ENV \
	$XF86_VIDEO_GEODE_ENV \
	./configure --build=$BUILD_ARCH --host=$TARGET_ARCH \
	    --prefix=/usr \
	    --sysconfdir=/etc \
	    || error
    ) || error "configure"
    
    make $MAKEARGS || error

    install_fakeroot_init

    install_fakeroot_finish || error

    #$INSTALL -D -m 644 src/.libs/geode_drv.so $ROOTFS_DIR/usr/lib/xorg/modules/drivers/geode_drv.so || error
    #$STRIP $ROOTFS_DIR/usr/lib/xorg/modules/drivers/geode_drv.so

    #$INSTALL -D -m 644 src/.libs/ztv_drv.so $ROOTFS_DIR/usr/lib/xorg/modules/drivers/ztv_drv.so || error
    #$STRIP $ROOTFS_DIR/usr/lib/xorg/modules/drivers/ztv_drv.so

    popd
    touch "$STATE_DIR/xf86_video_geode-${XF86_VIDEO_GEODE_VERSION}.installed"
}

build_xf86_video_geode
