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

XF86_VIDEO_NSC_VERSION=2.8.3
XF86_VIDEO_NSC=xf86-video-nsc-${XF86_VIDEO_NSC_VERSION}.tar.bz2
XF86_VIDEO_NSC_MIRROR=ftp://ftp.freedesktop.org/pub/xorg/individual/driver
XF86_VIDEO_NSC_DIR=$BUILD_DIR/xf86-video-nsc-${XF86_VIDEO_NSC_VERSION}
XF86_VIDEO_NSC_ENV="$CROSS_ENV_AC"

build_xf86_video_nsc() {
    test -e "$STATE_DIR/xf86_video_nsc.installed" && return
    banner "Build xf86-video-nsc"
    download $XF86_VIDEO_NSC_MIRROR $XF86_VIDEO_NSC
    extract $XF86_VIDEO_NSC
    apply_patches $XF86_VIDEO_NSC_DIR $XF86_VIDEO_NSC
    pushd $TOP_DIR
    cd $XF86_VIDEO_NSC_DIR
    (
    eval \
	$CROSS_CONF_ENV \
	$XF86_VIDEO_NSC_ENV \
	./configure --build=$BUILD_ARCH --host=$TARGET_ARCH \
	    --prefix=/usr \
	    --sysconfdir=/etc \
	    || error
    ) || error "configure"
    
    make $MAKEARGS || error

    $INSTALL -D -m 644 src/.libs/nsc_drv.so $ROOTFS_DIR/usr/lib/xorg/modules/drivers/nsc_drv.so || error
    $STRIP $ROOTFS_DIR/usr/lib/xorg/modules/drivers/nsc_drv.so

    popd
    touch "$STATE_DIR/xf86_video_nsc.installed"
}

build_xf86_video_nsc
