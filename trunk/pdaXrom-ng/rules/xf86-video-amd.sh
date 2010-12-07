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

XF86_VIDEO_AMD_VERSION=2.7.7.7
XF86_VIDEO_AMD=xf86-video-amd-${XF86_VIDEO_AMD_VERSION}.tar.bz2
XF86_VIDEO_AMD_MIRROR=ftp://ftp.freedesktop.org/pub/xorg/individual/driver
XF86_VIDEO_AMD_DIR=$BUILD_DIR/xf86-video-amd-${XF86_VIDEO_AMD_VERSION}
XF86_VIDEO_AMD_ENV="$CROSS_ENV_AC"

build_xf86_video_amd() {
    test -e "$STATE_DIR/xf86_video_amd.installed" && return
    banner "Build xf86-video-amd"
    download $XF86_VIDEO_AMD_MIRROR $XF86_VIDEO_AMD
    extract $XF86_VIDEO_AMD
    apply_patches $XF86_VIDEO_AMD_DIR $XF86_VIDEO_AMD
    pushd $TOP_DIR
    cd $XF86_VIDEO_AMD_DIR
    (
    eval \
	$CROSS_CONF_ENV \
	$XF86_VIDEO_AMD_ENV \
	./configure --build=$BUILD_ARCH --host=$TARGET_ARCH \
	    --prefix=/usr \
	    --sysconfdir=/etc \
	    || error
    ) || error "configure"
    
    make $MAKEARGS || error

    install_fakeroot_init

    install_fakeroot_finish || error

    #$INSTALL -D -m 644 src/.libs/amd_drv.so $ROOTFS_DIR/usr/lib/xorg/modules/drivers/amd_drv.so || error
    #$STRIP $ROOTFS_DIR/usr/lib/xorg/modules/drivers/amd_drv.so

    #$INSTALL -D -m 644 src/.libs/ztv_drv.so $ROOTFS_DIR/usr/lib/xorg/modules/drivers/ztv_drv.so || error
    #$STRIP $ROOTFS_DIR/usr/lib/xorg/modules/drivers/ztv_drv.so

    popd
    touch "$STATE_DIR/xf86_video_amd.installed"
}

build_xf86_video_amd
