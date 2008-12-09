#
# packet template
#
# Copyright (C) 2004 by Alexander Chukov <sash@pdaXrom.org>
#          
# See CREDITS for details about who has contributed to this project.
#
# For further information about the pdaXrom project and license conditions
# see the README file.
#

UDEV=udev-135.tar.bz2
UDEV_MIRROR=http://www.kernel.org/pub/linux/utils/kernel/hotplug
UDEV_DIR=$BUILD_DIR/udev-135
UDEV_ENV=

build_udev() {
    test -e "$STATE_DIR/udev-135" && return
    banner "Build $UDEV"
    download $UDEV_MIRROR $UDEV
    extract $UDEV
    apply_patches $UDEV_DIR $UDEV
    pushd $TOP_DIR
    cd $UDEV_DIR
    eval $UDEV_ENV \
	./configure --host=$TARGET_ARCH \
	    --prefix=/ \
	    --sysconfdir=/etc || error
    make $MAKEARGS || error

    mkdir -p $ROOTFS_DIR/etc/init.d
    mkdir -p $ROOTFS_DIR/etc/udev/rules.d
    mkdir -p $ROOTFS_DIR/etc/udev/scripts
    mkdir -p $ROOTFS_DIR/sbin
    $INSTALL -m 755 udev/udevd udev/udevadm $ROOTFS_DIR/sbin/
    $INSTALL -m 644 $GENERICFS_DIR/etc/udev/udev.conf  $ROOTFS_DIR/etc/udev/
    $INSTALL -m 644 $GENERICFS_DIR/etc/udev/links.conf $ROOTFS_DIR/etc/udev/
    $INSTALL -m 644 $GENERICFS_DIR/etc/udev/rules.d/udev.rules $ROOTFS_DIR/etc/udev/rules.d/
    for f in $GENERICFS_DIR/etc/udev/scripts/*; do
	$INSTALL -m 755 $f $ROOTFS_DIR/etc/udev/scripts/
    done
    $INSTALL -m 755 $GENERICFS_DIR/etc/init.d/udev $ROOTFS_DIR/etc/init.d/
    install_rc_start udev 00

    popd
    touch "$STATE_DIR/udev-135"
}

build_udev
