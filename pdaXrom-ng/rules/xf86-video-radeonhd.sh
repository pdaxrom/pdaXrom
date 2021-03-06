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

XF86_VIDEO_RADEONHD_VERSION=1.3.0
XF86_VIDEO_RADEONHD=xf86-video-radeonhd-${XF86_VIDEO_RADEONHD_VERSION}.tar.bz2
XF86_VIDEO_RADEONHD_MIRROR=ftp://ftp.freedesktop.org/pub/xorg/individual/driver
XF86_VIDEO_RADEONHD_DIR=$BUILD_DIR/xf86-video-radeonhd-${XF86_VIDEO_RADEONHD_VERSION}
XF86_VIDEO_RADEONHD_ENV="$CROSS_ENV_AC"

build_xf86_video_radeonhd() {
    test -e "$STATE_DIR/xf86_video_radeonhd.installed" && return
    banner "Build xf86-video-radeonhd"
    download $XF86_VIDEO_RADEONHD_MIRROR $XF86_VIDEO_RADEONHD
    extract $XF86_VIDEO_RADEONHD
    apply_patches $XF86_VIDEO_RADEONHD_DIR $XF86_VIDEO_RADEONHD
    pushd $TOP_DIR
    cd $XF86_VIDEO_RADEONHD_DIR
    (
    eval \
	$CROSS_CONF_ENV \
	$XF86_VIDEO_RADEONHD_ENV \
	./configure --build=$BUILD_ARCH --host=$TARGET_ARCH \
	    --prefix=/usr \
	    --sysconfdir=/etc \
	    || error
    ) || error "configure"
    
    make $MAKEARGS || error

    install_fakeroot_init

    install_fakeroot_finish || error

    #$INSTALL -D -m 644 src/.libs/radeonhd_drv.so $ROOTFS_DIR/usr/lib/xorg/modules/drivers/radeonhd_drv.so || error
    #$STRIP $ROOTFS_DIR/usr/lib/xorg/modules/drivers/radeonhd_drv.so

    popd
    touch "$STATE_DIR/xf86_video_radeonhd.installed"
}

build_xf86_video_radeonhd
