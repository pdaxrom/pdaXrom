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

XF86_VIDEO_SIS=xf86-video-sis-0.10.1.tar.bz2
XF86_VIDEO_SIS_MIRROR=ftp://ftp.freedesktop.org/pub/xorg/individual/driver
XF86_VIDEO_SIS_DIR=$BUILD_DIR/xf86-video-sis-0.10.1
XF86_VIDEO_SIS_ENV="$CROSS_ENV_AC"

build_xf86_video_sis() {
    test -e "$STATE_DIR/xf86_video_sis.installed" && return
    banner "Build xf86-video-sis"
    download $XF86_VIDEO_SIS_MIRROR $XF86_VIDEO_SIS
    extract $XF86_VIDEO_SIS
    apply_patches $XF86_VIDEO_SIS_DIR $XF86_VIDEO_SIS
    pushd $TOP_DIR
    cd $XF86_VIDEO_SIS_DIR
    (
    eval \
	$CROSS_CONF_ENV \
	$XF86_VIDEO_SIS_ENV \
	./configure --build=$BUILD_ARCH --host=$TARGET_ARCH \
	    --prefix=/usr \
	    --sysconfdir=/etc \
	    || error
    ) || error "configure"
    
    make $MAKEARGS || error

    $INSTALL -D -m 644 src/.libs/sis_drv.so $ROOTFS_DIR/usr/lib/xorg/modules/drivers/sis_drv.so || error
    $STRIP $ROOTFS_DIR/usr/lib/xorg/modules/drivers/sis_drv.so

    popd
    touch "$STATE_DIR/xf86_video_sis.installed"
}

build_xf86_video_sis
