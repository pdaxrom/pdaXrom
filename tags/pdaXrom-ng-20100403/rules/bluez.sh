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

BLUEZ_VERSION=4.29
BLUEZ=bluez-${BLUEZ_VERSION}.tar.gz
BLUEZ_MIRROR=http://www.kernel.org/pub/linux/bluetooth
BLUEZ_DIR=$BUILD_DIR/bluez-${BLUEZ_VERSION}
BLUEZ_ENV="$CROSS_ENV_AC"

build_bluez() {
    test -e "$STATE_DIR/bluez.installed" && return
    banner "Build bluez"
    download $BLUEZ_MIRROR $BLUEZ
    extract $BLUEZ
    apply_patches $BLUEZ_DIR $BLUEZ
    pushd $TOP_DIR
    cd $BLUEZ_DIR
    (
    eval \
	$CROSS_CONF_ENV \
	$BLUEZ_ENV \
	./configure --build=$BUILD_ARCH --host=$TARGET_ARCH \
	    --prefix=/usr \
	    --sysconfdir=/etc \
	    --localstatedir=/var \
	    --enable-usb \
	    --enable-netlink \
	    --enable-tools \
	    --enable-bccmd \
	    --enable-hid2hci \
	    --enable-dfutool \
	    --enable-hidd \
	    --enable-pand \
	    --enable-dund \
	    || error
    ) || error "configure"
    
    make $MAKEARGS || error

    install_sysroot_files || error

    make DESTDIR=$BLUEZ_DIR/fakeroot install || error

    rm -rf fakeroot/usr/include fakeroot/usr/lib/pkgconfig fakeroot/usr/share

    find fakeroot/ -name "*.la" | xargs rm -f

    find fakeroot/ -executable | while read f; do
	$STRIP $f
    done

    cp -R fakeroot/etc $ROOTFS_DIR/ || error "install etc"
    cp -R fakeroot/usr $ROOTFS_DIR/ || error "install usr"
    cp -R fakeroot/var $ROOTFS_DIR/ || error "install var"

    $INSTALL -D -m 644 scripts/bluetooth.default $ROOTFS_DIR/etc/default/bluetooth || error
    $INSTALL -D -m 644 scripts/bluetooth.rules $ROOTFS_DIR/lib/udev/rules.d/50-bluetooth.rules || error
    $INSTALL -D -m 755 scripts/bluetooth_serial $ROOTFS_DIR/lib/udev/bluetooth_serial || error
    $INSTALL -D -m 755 $GENERICFS_DIR/etc/init.d/bluetooth $ROOTFS_DIR/etc/init.d/bluetooth || error
    
    install_rc_start bluetooth 70
    install_rc_stop  bluetooth 20

    popd
    touch "$STATE_DIR/bluez.installed"
}

build_bluez
