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

XF86_VIDEO_INTEL_VERSION=2.6.2
XF86_VIDEO_INTEL=xf86-video-intel-${XF86_VIDEO_INTEL_VERSION}.tar.bz2
XF86_VIDEO_INTEL_MIRROR=ftp://ftp.freedesktop.org/pub/xorg/individual/driver
XF86_VIDEO_INTEL_DIR=$BUILD_DIR/xf86-video-intel-${XF86_VIDEO_INTEL_VERSION}
XF86_VIDEO_INTEL_ENV="$CROSS_ENV_AC"

build_xf86_video_intel() {
    test -e "$STATE_DIR/xf86_video_intel-${XF86_VIDEO_INTEL_VERSION}.installed" && return
    banner "Build xf86-video-intel"
    download $XF86_VIDEO_INTEL_MIRROR $XF86_VIDEO_INTEL
    extract $XF86_VIDEO_INTEL
    apply_patches $XF86_VIDEO_INTEL_DIR $XF86_VIDEO_INTEL
    pushd $TOP_DIR
    cd $XF86_VIDEO_INTEL_DIR
    (
    eval \
	$CROSS_CONF_ENV \
	$XF86_VIDEO_INTEL_ENV \
	./configure --build=$BUILD_ARCH --host=$TARGET_ARCH \
	    --prefix=/usr \
	    --sysconfdir=/etc \
	    || error
    ) || error "configure"
    
    make $MAKEARGS || error

    $INSTALL -D -m 644 src/.libs/intel_drv.so $ROOTFS_DIR/usr/lib/xorg/modules/drivers/intel_drv.so || error
    $STRIP $ROOTFS_DIR/usr/lib/xorg/modules/drivers/intel_drv.so

    popd
    touch "$STATE_DIR/xf86_video_intel-${XF86_VIDEO_INTEL_VERSION}.installed"
}

build_xf86_video_intel
