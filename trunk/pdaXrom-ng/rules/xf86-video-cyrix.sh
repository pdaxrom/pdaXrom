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

XF86_VIDEO_CYRIX_VERSION=1.1.0
XF86_VIDEO_CYRIX=xf86-video-cyrix-${XF86_VIDEO_CYRIX_VERSION}.tar.bz2
XF86_VIDEO_CYRIX_MIRROR=ftp://ftp.freedesktop.org/pub/xorg/individual/driver
XF86_VIDEO_CYRIX_DIR=$BUILD_DIR/xf86-video-cyrix-${XF86_VIDEO_CYRIX_VERSION}
XF86_VIDEO_CYRIX_ENV="$CROSS_ENV_AC"

build_xf86_video_cyrix() {
    test -e "$STATE_DIR/xf86_video_cyrix.installed" && return
    banner "Build xf86-video-cyrix"
    download $XF86_VIDEO_CYRIX_MIRROR $XF86_VIDEO_CYRIX
    extract $XF86_VIDEO_CYRIX
    apply_patches $XF86_VIDEO_CYRIX_DIR $XF86_VIDEO_CYRIX
    pushd $TOP_DIR
    cd $XF86_VIDEO_CYRIX_DIR
    (
    eval \
	$CROSS_CONF_ENV \
	$XF86_VIDEO_CYRIX_ENV \
	./configure --build=$BUILD_ARCH --host=$TARGET_ARCH \
	    --prefix=/usr \
	    --sysconfdir=/etc \
	    || error
    ) || error "configure"
    
    make $MAKEARGS || error

    $INSTALL -D -m 644 src/.libs/cyrix_drv.so $ROOTFS_DIR/usr/lib/xorg/modules/drivers/cyrix_drv.so || error
    $STRIP $ROOTFS_DIR/usr/lib/xorg/modules/drivers/cyrix_drv.so

    error "update install"

    popd
    touch "$STATE_DIR/xf86_video_cyrix.installed"
}

build_xf86_video_cyrix
