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

XF86_VIDEO_GLINT_VERSION=1.2.5
XF86_VIDEO_GLINT=xf86-video-glint-${XF86_VIDEO_GLINT_VERSION}.tar.bz2
XF86_VIDEO_GLINT_MIRROR=ftp://ftp.freedesktop.org/pub/xorg/individual/driver
XF86_VIDEO_GLINT_DIR=$BUILD_DIR/xf86-video-glint-${XF86_VIDEO_GLINT_VERSION}
XF86_VIDEO_GLINT_ENV="$CROSS_ENV_AC"

build_xf86_video_glint() {
    test -e "$STATE_DIR/xf86_video_glint.installed" && return
    banner "Build xf86-video-glint"
    download $XF86_VIDEO_GLINT_MIRROR $XF86_VIDEO_GLINT
    extract $XF86_VIDEO_GLINT
    apply_patches $XF86_VIDEO_GLINT_DIR $XF86_VIDEO_GLINT
    pushd $TOP_DIR
    cd $XF86_VIDEO_GLINT_DIR
    (
    eval \
	$CROSS_CONF_ENV \
	$XF86_VIDEO_GLINT_ENV \
	./configure --build=$BUILD_ARCH --host=$TARGET_ARCH \
	    --prefix=/usr \
	    --sysconfdir=/etc \
	    || error
    ) || error "configure"
    
    make $MAKEARGS || error

    $INSTALL -D -m 644 src/.libs/glint_drv.so $ROOTFS_DIR/usr/lib/xorg/modules/drivers/glint_drv.so || error
    $STRIP $ROOTFS_DIR/usr/lib/xorg/modules/drivers/glint_drv.so

    popd
    touch "$STATE_DIR/xf86_video_glint.installed"
}

build_xf86_video_glint
