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

UDEV_VERSION=164
UDEV=udev-${UDEV_VERSION}.tar.bz2
UDEV_MIRROR=http://www.kernel.org/pub/linux/utils/kernel/hotplug
UDEV_DIR=$BUILD_DIR/udev-${UDEV_VERSION}
UDEV_ENV="$CROSS_ENV_AC"

build_udev() {
    test -e "$STATE_DIR/udev.installed" && return
    banner "Build udev"
    download $UDEV_MIRROR $UDEV
    extract $UDEV
    apply_patches $UDEV_DIR $UDEV
    pushd $TOP_DIR
    cd $UDEV_DIR
    (
    eval \
	$CROSS_CONF_ENV \
	$UDEV_ENV \
	./configure --build=$BUILD_ARCH --host=$TARGET_ARCH \
	    --prefix=/usr \
	    --sysconfdir=/etc \
	    --bindir=/bin \
	    --sbindir=/sbin \
	    --libdir=/lib \
	    --libexecdir=/lib/udev \
	    --disable-introspection \
	    --with-pci-ids-path=/usr/share/hwdata \
	    || error
    ) || error "configure"

    make $MAKEARGS || error

    install_sysroot_files || error

    install_fakeroot_init

    rm -rf fakeroot/usr/share/pkgconfig

    install_fakeroot_finish || error

    $INSTALL -D -m 755 $GENERICFS_DIR/etc/init.d/udev $ROOTFS_DIR/etc/init.d/udev || error

    if [ "$USE_FASTBOOT" = "yes" ]; then
	install_rc_start udev 04
    else
	install_rc_start udev 00
    fi
    install_rc_stop  udev 97

    popd
    touch "$STATE_DIR/udev.installed"
}

build_udev
