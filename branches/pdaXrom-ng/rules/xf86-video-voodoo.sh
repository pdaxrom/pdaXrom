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

XF86_VIDEO_VOODOO=xf86-video-voodoo-1.2.0.tar.bz2
XF86_VIDEO_VOODOO_MIRROR=ftp://ftp.freedesktop.org/pub/xorg/individual/driver
XF86_VIDEO_VOODOO_DIR=$BUILD_DIR/xf86-video-voodoo-1.2.0
XF86_VIDEO_VOODOO_ENV="$CROSS_ENV_AC"

build_xf86_video_voodoo() {
    test -e "$STATE_DIR/xf86_video_voodoo.installed" && return
    banner "Build xf86-video-voodoo"
    download $XF86_VIDEO_VOODOO_MIRROR $XF86_VIDEO_VOODOO
    extract $XF86_VIDEO_VOODOO
    apply_patches $XF86_VIDEO_VOODOO_DIR $XF86_VIDEO_VOODOO
    pushd $TOP_DIR
    cd $XF86_VIDEO_VOODOO_DIR
    (
    eval \
	$CROSS_CONF_ENV \
	$XF86_VIDEO_VOODOO_ENV \
	./configure --build=$BUILD_ARCH --host=$TARGET_ARCH \
	    --prefix=/usr \
	    --sysconfdir=/etc \
	    || error
    ) || error "configure"
    
    make $MAKEARGS || error

    $INSTALL -D -m 644 src/.libs/voodoo_drv.so $ROOTFS_DIR/usr/lib/xorg/modules/drivers/voodoo_drv.so || error
    $STRIP $ROOTFS_DIR/usr/lib/xorg/modules/drivers/voodoo_drv.so

    popd
    touch "$STATE_DIR/xf86_video_voodoo.installed"
}

build_xf86_video_voodoo
