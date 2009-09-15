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

XF86_VIDEO_DUMMY_VERSION=0.3.1
XF86_VIDEO_DUMMY=xf86-video-dummy-${XF86_VIDEO_DUMMY_VERSION}.tar.bz2
XF86_VIDEO_DUMMY_MIRROR=ftp://ftp.freedesktop.org/pub/xorg/individual/driver
XF86_VIDEO_DUMMY_DIR=$BUILD_DIR/xf86-video-dummy-${XF86_VIDEO_DUMMY_VERSION}
XF86_VIDEO_DUMMY_ENV="$CROSS_ENV_AC"

build_xf86_video_dummy() {
    test -e "$STATE_DIR/xf86_video_dummy-${XF86_VIDEO_DUMMY_VERSION}.installed" && return
    banner "Build xf86-video-dummy"
    download $XF86_VIDEO_DUMMY_MIRROR $XF86_VIDEO_DUMMY
    extract $XF86_VIDEO_DUMMY
    apply_patches $XF86_VIDEO_DUMMY_DIR $XF86_VIDEO_DUMMY
    pushd $TOP_DIR
    cd $XF86_VIDEO_DUMMY_DIR
    (
    eval \
	$CROSS_CONF_ENV \
	$XF86_VIDEO_DUMMY_ENV \
	./configure --build=$BUILD_ARCH --host=$TARGET_ARCH \
	    --prefix=/usr \
	    --sysconfdir=/etc \
	    || error
    ) || error "configure"
    
    make $MAKEARGS || error

    $INSTALL -D -m 644 src/.libs/dummy_drv.so $ROOTFS_DIR/usr/lib/xorg/modules/drivers/dummy_drv.so || error
    $STRIP $ROOTFS_DIR/usr/lib/xorg/modules/drivers/dummy_drv.so

    popd
    touch "$STATE_DIR/xf86_video_dummy-${XF86_VIDEO_DUMMY_VERSION}.installed"
}

build_xf86_video_dummy
