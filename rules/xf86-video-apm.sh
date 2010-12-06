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

XF86_VIDEO_APM=xf86-video-apm-1.2.1.tar.bz2
XF86_VIDEO_APM_MIRROR=ftp://ftp.freedesktop.org/pub/xorg/individual/driver
XF86_VIDEO_APM_DIR=$BUILD_DIR/xf86-video-apm-1.2.1
XF86_VIDEO_APM_ENV="$CROSS_ENV_AC"

build_xf86_video_apm() {
    test -e "$STATE_DIR/xf86_video_apm.installed" && return
    banner "Build xf86-video-apm"
    download $XF86_VIDEO_APM_MIRROR $XF86_VIDEO_APM
    extract $XF86_VIDEO_APM
    apply_patches $XF86_VIDEO_APM_DIR $XF86_VIDEO_APM
    pushd $TOP_DIR
    cd $XF86_VIDEO_APM_DIR
    (
    eval \
	$CROSS_CONF_ENV \
	$XF86_VIDEO_APM_ENV \
	./configure --build=$BUILD_ARCH --host=$TARGET_ARCH \
	    --prefix=/usr \
	    --sysconfdir=/etc \
	    || error
    ) || error "configure"
    
    make $MAKEARGS || error

    $INSTALL -D -m 644 src/.libs/apm_drv.so $ROOTFS_DIR/usr/lib/xorg/modules/drivers/apm_drv.so || error
    $STRIP $ROOTFS_DIR/usr/lib/xorg/modules/drivers/apm_drv.so

    popd
    touch "$STATE_DIR/xf86_video_apm.installed"
}

build_xf86_video_apm
