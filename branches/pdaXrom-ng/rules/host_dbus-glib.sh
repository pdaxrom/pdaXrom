#
# host packet template
#
# Copyright (C) 2009 by Alexander Chukov <sash@pdaXrom.org>
#          
# See CREDITS for details about who has contributed to this project.
#
# For further information about the pdaXrom project and license conditions
# see the README file.
#

HOST_DBUS_GLIB=dbus-glib-0.78.tar.gz
HOST_DBUS_GLIB_MIRROR=http://dbus.freedesktop.org/releases/dbus-glib
HOST_DBUS_GLIB_DIR=$HOST_BUILD_DIR/dbus-glib-0.78
HOST_DBUS_GLIB_ENV="PKG_CONFIG=\"$HOST_PKG_CONFIG\" PKG_CONFIG_PATH=\"$HOST_BIN_DIR/lib/pkgconfig\" \
CPPFLAGS=\"-I$HOST_BIN_DIR/include\" \
LDFLAGS=\"-L$HOST_BIN_DIR/lib\""

build_host_dbus_glib() {
    test -e "$STATE_DIR/host_dbus_glib.installed" && return
    banner "Build host-dbus-glib"
    download $HOST_DBUS_GLIB_MIRROR $HOST_DBUS_GLIB
    extract_host $HOST_DBUS_GLIB
    apply_patches $HOST_DBUS_GLIB_DIR $HOST_DBUS_GLIB
    pushd $TOP_DIR
    cd $HOST_DBUS_GLIB_DIR
    (
    eval $HOST_DBUS_GLIB_ENV \
	./configure --prefix=$HOST_BIN_DIR
    ) || error
    make -C dbus $MAKEARGS || error
    make -C dbus $MAKEARGS install || error
    popd
    touch "$STATE_DIR/host_dbus_glib.installed"
}

build_host_dbus_glib
