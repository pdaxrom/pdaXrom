#
# host packet template
#
# Copyright (C) 2008 by Alexander Chukov <sash@pdaXrom.org>
#          
# See CREDITS for details about who has contributed to this project.
#
# For further information about the pdaXrom project and license conditions
# see the README file.
#

HOST_DBUS=dbus-1.2.10.tar.gz
HOST_DBUS_MIRROR=http://dbus.freedesktop.org/releases/dbus
HOST_DBUS_DIR=$HOST_BUILD_DIR/dbus-1.2.10
HOST_DBUS_ENV=

build_host_dbus() {
    test -e "$STATE_DIR/host_dbus.installed" && return
    banner "Build host-dbus"
    download $HOST_DBUS_MIRROR $HOST_DBUS
    extract_host $HOST_DBUS
    apply_patches $HOST_DBUS_DIR $HOST_DBUS
    pushd $TOP_DIR
    cd $HOST_DBUS_DIR
    (
    eval $HOST_DBUS_ENV \
	./configure --prefix=$HOST_BIN_DIR \
	    --disable-shared \
	    --enable-static
    ) || error
    make $MAKEARGS || error
    make $MAKEARGS install || error
    popd
    touch "$STATE_DIR/host_dbus.installed"
}

build_host_dbus
