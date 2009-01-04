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

XF86_VIDEO_ATI=xf86-video-ati-6.9.0.tar.bz2
XF86_VIDEO_ATI_MIRROR=ftp://ftp.freedesktop.org/pub/xorg/individual/driver
XF86_VIDEO_ATI_DIR=$BUILD_DIR/xf86-video-ati-6.9.0
XF86_VIDEO_ATI_ENV="$CROSS_ENV_AC"

build_xf86_video_ati() {
    test -e "$STATE_DIR/xf86_video_ati.installed" && return
    banner "Build xf86-video-ati"
    download $XF86_VIDEO_ATI_MIRROR $XF86_VIDEO_ATI
    extract $XF86_VIDEO_ATI
    apply_patches $XF86_VIDEO_ATI_DIR $XF86_VIDEO_ATI
    pushd $TOP_DIR
    cd $XF86_VIDEO_ATI_DIR
    (
    eval \
	$CROSS_CONF_ENV \
	$XF86_VIDEO_ATI_ENV \
	./configure --build=$BUILD_ARCH --host=$TARGET_ARCH \
	    --prefix=/usr \
	    --sysconfdir=/etc \
	    --enable-dri \
	    || error
    ) || error "configure"
    
    make $MAKEARGS || error

    cd src/.libs
    
    for f in *_drv.so; do
	$INSTALL -D -m 644 $f $ROOTFS_DIR/usr/lib/xorg/modules/drivers/$f || error
	$STRIP $ROOTFS_DIR/usr/lib/xorg/modules/drivers/$f
    done

    popd
    touch "$STATE_DIR/xf86_video_ati.installed"
}

build_xf86_video_ati
