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

XF86_VIDEO_NEOMAGIC=xf86-video-neomagic-1.2.2.tar.bz2
XF86_VIDEO_NEOMAGIC_MIRROR=ftp://ftp.freedesktop.org/pub/xorg/individual/driver
XF86_VIDEO_NEOMAGIC_DIR=$BUILD_DIR/xf86-video-neomagic-1.2.2
XF86_VIDEO_NEOMAGIC_ENV="$CROSS_ENV_AC"

build_xf86_video_neomagic() {
    test -e "$STATE_DIR/xf86_video_neomagic.installed" && return
    banner "Build xf86-video-neomagic"
    download $XF86_VIDEO_NEOMAGIC_MIRROR $XF86_VIDEO_NEOMAGIC
    extract $XF86_VIDEO_NEOMAGIC
    apply_patches $XF86_VIDEO_NEOMAGIC_DIR $XF86_VIDEO_NEOMAGIC
    pushd $TOP_DIR
    cd $XF86_VIDEO_NEOMAGIC_DIR
    (
    eval \
	$CROSS_CONF_ENV \
	$XF86_VIDEO_NEOMAGIC_ENV \
	./configure --build=$BUILD_ARCH --host=$TARGET_ARCH \
	    --prefix=/usr \
	    --sysconfdir=/etc \
	    || error
    ) || error "configure"
    
    make $MAKEARGS || error

    $INSTALL -D -m 644 src/.libs/neomagic_drv.so $ROOTFS_DIR/usr/lib/xorg/modules/drivers/neomagic_drv.so || error
    $STRIP $ROOTFS_DIR/usr/lib/xorg/modules/drivers/neomagic_drv.so

    popd
    touch "$STATE_DIR/xf86_video_neomagic.installed"
}

build_xf86_video_neomagic
