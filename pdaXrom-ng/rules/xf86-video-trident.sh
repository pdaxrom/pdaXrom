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

XF86_VIDEO_TRIDENT_VERSION=1.3.4
XF86_VIDEO_TRIDENT=xf86-video-trident-${XF86_VIDEO_TRIDENT_VERSION}.tar.bz2
XF86_VIDEO_TRIDENT_MIRROR=ftp://ftp.freedesktop.org/pub/xorg/individual/driver
XF86_VIDEO_TRIDENT_DIR=$BUILD_DIR/xf86-video-trident-${XF86_VIDEO_TRIDENT_VERSION}
XF86_VIDEO_TRIDENT_ENV="$CROSS_ENV_AC"

build_xf86_video_trident() {
    test -e "$STATE_DIR/xf86_video_trident.installed" && return
    banner "Build xf86-video-trident"
    download $XF86_VIDEO_TRIDENT_MIRROR $XF86_VIDEO_TRIDENT
    extract $XF86_VIDEO_TRIDENT
    apply_patches $XF86_VIDEO_TRIDENT_DIR $XF86_VIDEO_TRIDENT
    pushd $TOP_DIR
    cd $XF86_VIDEO_TRIDENT_DIR
    (
    eval \
	$CROSS_CONF_ENV \
	$XF86_VIDEO_TRIDENT_ENV \
	./configure --build=$BUILD_ARCH --host=$TARGET_ARCH \
	    --prefix=/usr \
	    --sysconfdir=/etc \
	    || error
    ) || error "configure"
    
    make $MAKEARGS || error

    $INSTALL -D -m 644 src/.libs/trident_drv.so $ROOTFS_DIR/usr/lib/xorg/modules/drivers/trident_drv.so || error
    $STRIP $ROOTFS_DIR/usr/lib/xorg/modules/drivers/trident_drv.so

    popd
    touch "$STATE_DIR/xf86_video_trident.installed"
}

build_xf86_video_trident
