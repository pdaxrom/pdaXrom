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

XF86_VIDEO_OPENCHROME=xf86-video-openchrome-0.2.903.tar.bz2
XF86_VIDEO_OPENCHROME_MIRROR=ftp://ftp.freedesktop.org/pub/xorg/individual/driver
XF86_VIDEO_OPENCHROME_DIR=$BUILD_DIR/xf86-video-openchrome-0.2.903
XF86_VIDEO_OPENCHROME_ENV="$CROSS_ENV_AC"

build_xf86_video_openchrome() {
    test -e "$STATE_DIR/xf86_video_openchrome.installed" && return
    banner "Build xf86-video-openchrome"
    download $XF86_VIDEO_OPENCHROME_MIRROR $XF86_VIDEO_OPENCHROME
    extract $XF86_VIDEO_OPENCHROME
    apply_patches $XF86_VIDEO_OPENCHROME_DIR $XF86_VIDEO_OPENCHROME
    pushd $TOP_DIR
    cd $XF86_VIDEO_OPENCHROME_DIR
    (
    eval \
	$CROSS_CONF_ENV \
	$XF86_VIDEO_OPENCHROME_ENV \
	./configure --build=$BUILD_ARCH --host=$TARGET_ARCH \
	    --prefix=/usr \
	    --sysconfdir=/etc \
	    || error
    ) || error "configure"
    
    make $MAKEARGS || error

    $INSTALL -D -m 644 src/.libs/openchrome_drv.so $ROOTFS_DIR/usr/lib/xorg/modules/drivers/openchrome_drv.so || error
    $STRIP $ROOTFS_DIR/usr/lib/xorg/modules/drivers/openchrome_drv.so

    $INSTALL -D -m 644 libxvmc/.libs/libchromeXvMC.so.1.0.0 $ROOTFS_DIR/usr/lib/libchromeXvMC.so.1.0.0 || error
    ln -sf libchromeXvMC.so.1.0.0 $ROOTFS_DIR/usr/lib/libchromeXvMC.so.1
    ln -sf libchromeXvMC.so.1.0.0 $ROOTFS_DIR/usr/lib/libchromeXvMC.so
    $STRIP $ROOTFS_DIR/usr/lib/libchromeXvMC.so.1.0.0
    
    $INSTALL -D -m 644 libxvmc/.libs/libchromeXvMCPro.so.1.0.0 $ROOTFS_DIR/usr/lib/libchromeXvMCPro.so.1.0.0 || error
    ln -sf libchromeXvMCPro.so.1.0.0 $ROOTFS_DIR/usr/lib/libchromeXvMCPro.so.1
    ln -sf libchromeXvMCPro.so.1.0.0 $ROOTFS_DIR/usr/lib/libchromeXvMCPro.so
    $STRIP $ROOTFS_DIR/usr/lib/libchromeXvMCPro.so.1.0.0

    popd
    touch "$STATE_DIR/xf86_video_openchrome.installed"
}

build_xf86_video_openchrome
