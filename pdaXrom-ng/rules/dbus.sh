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

DBUS_VERSION=1.4.0
DBUS=dbus-${DBUS_VERSION}.tar.gz
DBUS_MIRROR=http://dbus.freedesktop.org/releases/dbus
DBUS_DIR=$BUILD_DIR/dbus-${DBUS_VERSION}
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
    local C_ARGS=
    if [ -e $TARGET_LIB/libX11.so ]; then
	C_ARGS=" \
	    --with-x \
	    --x-includes=$TARGET_INC \
	    --x-libraries=$TARGET_LIB \
		"
    else
	C_ARGS="--with-x=no"
    fi

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
    	    $C_ARGS \
	    || error
    ) || error "configure"

    make $MAKEARGS || error

    install_sysroot_files || error

    install_fakeroot_init
    rm -rf fakeroot/usr/lib/dbus-1.0/include
    install_fakeroot_finish || error

    chmod 4755 ${ROOTFS_DIR}/usr/lib/dbus-1.0/dbus-daemon-launch-helper

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
