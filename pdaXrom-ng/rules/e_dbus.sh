#
# packet template
#
# Copyright (C) 2010 by Alexander Chukov <sash@pdaXrom.org>
#
# See CREDITS for details about who has contributed to this project.
#
# For further information about the pdaXrom project and license conditions
# see the README file.
#

E_DBUS_VERSION=1.0.0.beta3
E_DBUS=e_dbus-${E_DBUS_VERSION}.tar.bz2
E_DBUS_MIRROR=http://download.enlightenment.org/releases
E_DBUS_DIR=$BUILD_DIR/e_dbus-${E_DBUS_VERSION}
E_DBUS_ENV="$CROSS_ENV_AC LIBS=\"-Wl,-rpath,${E_DBUS_DIR}/src/lib/dbus/.libs\""

build_e_dbus() {
    test -e "$STATE_DIR/e_dbus.installed" && return
    banner "Build e_dbus"
    download $E_DBUS_MIRROR $E_DBUS
    extract $E_DBUS
    apply_patches $E_DBUS_DIR $E_DBUS
    pushd $TOP_DIR
    cd $E_DBUS_DIR
    (
    eval \
	$CROSS_CONF_ENV \
	$E_DBUS_ENV \
	./configure --build=$BUILD_ARCH --host=$TARGET_ARCH \
	    --prefix=/usr \
	    --sysconfdir=/etc \
	    || error
    ) || error "configure"

    make $MAKEARGS || error

    install_sysroot_files || error

    install_fakeroot_init

    install_fakeroot_finish || error

    popd
    touch "$STATE_DIR/e_dbus.installed"
}

build_e_dbus
