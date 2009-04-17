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

DBUS_GLIB=dbus-glib-0.78.tar.gz
DBUS_GLIB_MIRROR=http://dbus.freedesktop.org/releases/dbus-glib
DBUS_GLIB_DIR=$BUILD_DIR/dbus-glib-0.78
DBUS_GLIB_ENV="$CROSS_ENV_AC \
    ac_cv_func_posix_getpwnam_r=yes \
    ac_cv_have_abstract_sockets=no \
"

build_dbus_glib() {
    test -e "$STATE_DIR/dbus_glib.installed" && return
    banner "Build dbus-glib"
    download $DBUS_GLIB_MIRROR $DBUS_GLIB
    extract $DBUS_GLIB
    apply_patches $DBUS_GLIB_DIR $DBUS_GLIB
    pushd $TOP_DIR
    cd $DBUS_GLIB_DIR
    (
    eval \
	$CROSS_CONF_ENV \
	$DBUS_GLIB_ENV \
	./configure --build=$BUILD_ARCH --host=$TARGET_ARCH \
	    --prefix=/usr \
	    --sysconfdir=/etc \
	    --libexecdir=/usr/lib/dbus-1.0 \
	    --localstatedir=/var \
	    || error
    ) || error "configure"

    #sed -i "s| /usr/bin/dbus-daemon| dbus-daemon|" tools/Makefile
    
    make $MAKEARGS || error

    install_sysroot_files || error
    
    $INSTALL -D -m 755 dbus/.libs/dbus-binding-tool $ROOTFS_DIR/usr/bin/dbus-binding-tool || error
    $STRIP $ROOTFS_DIR/usr/bin/dbus-binding-tool
    $INSTALL -D -m 644 dbus/.libs/libdbus-glib-1.so.2.1.0 $ROOTFS_DIR/usr/lib/libdbus-glib-1.so.2.1.0 || error
    ln -sf libdbus-glib-1.so.2.1.0 $ROOTFS_DIR/usr/lib/libdbus-glib-1.so.2
    ln -sf libdbus-glib-1.so.2.1.0 $ROOTFS_DIR/usr/lib/libdbus-glib-1.so
    $STRIP $ROOTFS_DIR/usr/lib/libdbus-glib-1.so.2.1.0

    popd
    touch "$STATE_DIR/dbus_glib.installed"
}

build_dbus_glib
