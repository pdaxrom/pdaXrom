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

DBUS=dbus-1.2.10.tar.gz
DBUS_MIRROR=http://dbus.freedesktop.org/releases/dbus
DBUS_DIR=$BUILD_DIR/dbus-1.2.10
DBUS_ENV="$CROSS_ENV_AC ac_cv_have_abstract_sockets=no"

build_dbus() {
    test -e "$STATE_DIR/dbus.installed" && return
    banner "Build dbus"
    download $DBUS_MIRROR $DBUS
    extract $DBUS
    apply_patches $DBUS_DIR $DBUS
    pushd $TOP_DIR
    cd $DBUS_DIR
    (
    eval \
	$CROSS_CONF_ENV \
	$DBUS_ENV \
	./configure --build=$BUILD_ARCH --host=$TARGET_ARCH \
	    --prefix=/usr \
	    --sysconfdir=/etc \
	    --with-xml=expat \
	    --libexecdir=/usr/lib/dbus-1.0 \
	    --localstatedir=/var \
	    --disable-tests \
	    --disable-checks \
    	    --disable-xml-docs \
    	    --disable-doxygen-docs \
	    --with-x \
	    --x-includes=$TARGET_INC \
	    --x-libraries=$TARGET_LIB \
	    || error
    ) || error "configure"
    
    make $MAKEARGS || error

    install_sysroot_files || error

    $INSTALL -d $ROOTFS_DIR/etc/dbus-1/session.d || error
    $INSTALL -d $ROOTFS_DIR/etc/dbus-1/system.d  || error
    $INSTALL -D -m 644 bus/session.conf $ROOTFS_DIR/etc/dbus-1/session.conf || error
    $INSTALL -D -m 644 bus/system.conf  $ROOTFS_DIR/etc/dbus-1/system.conf  || error
    
    $INSTALL -D -m 755 tools/dbus-cleanup-sockets $ROOTFS_DIR/usr/bin/dbus-cleanup-sockets || error
    $STRIP $ROOTFS_DIR/usr/bin/dbus-cleanup-sockets
    $INSTALL -D -m 755 tools/dbus-launch $ROOTFS_DIR/usr/bin/dbus-launch || error
    $STRIP $ROOTFS_DIR/usr/bin/dbus-launch
    $INSTALL -D -m 755 tools/.libs/dbus-monitor $ROOTFS_DIR/usr/bin/dbus-monitor || error
    $STRIP $ROOTFS_DIR/usr/bin/dbus-monitor
    $INSTALL -D -m 755 tools/.libs/dbus-send $ROOTFS_DIR/usr/bin/dbus-send || error
    $STRIP $ROOTFS_DIR/usr/bin/dbus-send
    $INSTALL -D -m 755 tools/.libs/dbus-uuidgen $ROOTFS_DIR/usr/bin/dbus-uuidgen || error
    $STRIP $ROOTFS_DIR/usr/bin/dbus-uuidgen

    $INSTALL -D -m 755 bus/dbus-daemon $ROOTFS_DIR/usr/bin/dbus-daemon || error
    $STRIP $ROOTFS_DIR/usr/bin/dbus-daemon

    $INSTALL -d $ROOTFS_DIR/usr/lib/dbus-1.0/dbus-1
    $INSTALL -D -m 755 bus/dbus-daemon-launch-helper $ROOTFS_DIR/usr/lib/dbus-1.0/dbus-daemon-launch-helper || error
    $STRIP $ROOTFS_DIR/usr/lib/dbus-1.0/dbus-daemon-launch-helper
    $INSTALL -D dbus/.libs/libdbus-1.so.3.4.0 $ROOTFS_DIR/usr/lib/libdbus-1.so.3.4.0 || error
    ln -sf libdbus-1.so.3.4.0 $ROOTFS_DIR/usr/lib/libdbus-1.so.3
    ln -sf libdbus-1.so.3.4.0 $ROOTFS_DIR/usr/lib/libdbus-1.so
    $STRIP $ROOTFS_DIR/usr/lib/libdbus-1.so.3.4.0

    $INSTALL -d $ROOTFS_DIR/usr/share/dbus-1/services || error
    $INSTALL -d $ROOTFS_DIR/usr/share/dbus-1/system-services || error
    
    $INSTALL -d $ROOTFS_DIR/var/lib/dbus || error
    $INSTALL -d $ROOTFS_DIR/var/run/dbus || error

    $INSTALL -D -m 755 $GENERICFS_DIR/etc/init.d/dbus $ROOTFS_DIR/etc/init.d/dbus || error
    if [ "$USE_FASTBOOT" = "yes" ]; then
	install_rc_start dbus 00
    else
	install_rc_start dbus 10
    fi
    install_rc_stop  dbus 71

    popd
    touch "$STATE_DIR/dbus.installed"
}

build_dbus
