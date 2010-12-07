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

XF86_VIDEO_XGI_VERSION=1.6.0
XF86_VIDEO_XGI=xf86-video-xgi-${XF86_VIDEO_XGI_VERSION}.tar.bz2
XF86_VIDEO_XGI_MIRROR=ftp://ftp.freedesktop.org/pub/xorg/individual/driver
XF86_VIDEO_XGI_DIR=$BUILD_DIR/xf86-video-xgi-${XF86_VIDEO_XGI_VERSION}
XF86_VIDEO_XGI_ENV="$CROSS_ENV_AC"

build_xf86_video_xgi() {
    test -e "$STATE_DIR/xf86_video_xgi.installed" && return
    banner "Build xf86-video-xgi"
    download $XF86_VIDEO_XGI_MIRROR $XF86_VIDEO_XGI
    extract $XF86_VIDEO_XGI
    apply_patches $XF86_VIDEO_XGI_DIR $XF86_VIDEO_XGI
    pushd $TOP_DIR
    cd $XF86_VIDEO_XGI_DIR
    (
    eval \
	$CROSS_CONF_ENV \
	$XF86_VIDEO_XGI_ENV \
	./configure --build=$BUILD_ARCH --host=$TARGET_ARCH \
	    --prefix=/usr \
	    --sysconfdir=/etc \
	    || error
    ) || error "configure"
    
    make $MAKEARGS || error

    $INSTALL -D -m 644 src/.libs/xgi_drv.so $ROOTFS_DIR/usr/lib/xorg/modules/drivers/xgi_drv.so || error
    $STRIP $ROOTFS_DIR/usr/lib/xorg/modules/drivers/xgi_drv.so

    popd
    touch "$STATE_DIR/xf86_video_xgi.installed"
}

build_xf86_video_xgi
