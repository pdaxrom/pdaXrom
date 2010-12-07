#
# packet template
#
# Copyright (C) 2008 by Alexander Chukov <sash@pdaXrom.org>
#          
# See CREDITS for details about who has contributed to this project.
#
# For further information about the pdaXrom project and license conditions
# see the README file.
#

XF86_VIDEO_VMWARE_VERSION=11.0.3
XF86_VIDEO_VMWARE=xf86-video-vmware-${XF86_VIDEO_VMWARE_VERSION}.tar.bz2
XF86_VIDEO_VMWARE_MIRROR=ftp://ftp.freedesktop.org/pub/xorg/individual/driver
XF86_VIDEO_VMWARE_DIR=$BUILD_DIR/xf86-video-vmware-${XF86_VIDEO_VMWARE_VERSION}
XF86_VIDEO_VMWARE_ENV=

build_xf86_video_vmware() {
    test -e "$STATE_DIR/xf86_video_vmware-${XF86_VIDEO_VMWARE_VERSION}" && return
    banner "Build $XF86_VIDEO_VMWARE"
    download $XF86_VIDEO_VMWARE_MIRROR $XF86_VIDEO_VMWARE
    extract $XF86_VIDEO_VMWARE
    apply_patches $XF86_VIDEO_VMWARE_DIR $XF86_VIDEO_VMWARE
    pushd $TOP_DIR
    cd $XF86_VIDEO_VMWARE_DIR
    (
    eval \
	$CROSS_CONF_ENV \
	$XF86_VIDEO_VMWARE_ENV \
	./configure --build=$BUILD_ARCH --host=$TARGET_ARCH \
	    --prefix=/usr \
	    --sysconfdir=/etc \
	    || error
    )
    make $MAKEARGS || error

    $INSTALL -D -m 644 src/.libs/vmware_drv.so $ROOTFS_DIR/usr/lib/xorg/modules/drivers/vmware_drv.so || error
    $STRIP $ROOTFS_DIR/usr/lib/xorg/modules/drivers/vmware_drv.so

    popd
    touch "$STATE_DIR/xf86_video_vmware-${XF86_VIDEO_VMWARE_VERSION}"
}

build_xf86_video_vmware
