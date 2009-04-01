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

GLIB2_VERSION=2.20.0
GLIB2=glib-${GLIB2_VERSION}.tar.bz2
GLIB2_MIRROR=http://ftp.gtk.org/pub/glib/2.20
GLIB2_DIR=$BUILD_DIR/glib-${GLIB2_VERSION}
GLIB2_ENV="$CROSS_ENV_AC glib_cv_uscore=no glib_cv_stack_grows=no"

build_glib2() {
    test -e "$STATE_DIR/glib2.installed" && return
    banner "Build glib2"
    download $GLIB2_MIRROR $GLIB2
    extract $GLIB2
    apply_patches $GLIB2_DIR $GLIB2
    pushd $TOP_DIR
    cd $GLIB2_DIR
    (
    eval \
	$CROSS_CONF_ENV \
	$GLIB2_ENV \
	./configure --build=$BUILD_ARCH --host=$TARGET_ARCH \
	    --prefix=/usr \
	    --sysconfdir=/etc \
	    || error
    ) || error

    make $MAKEARGS || error

    install_sysroot_files || error
    
    $INSTALL -D -m 644 gio/.libs/libgio-2.0.so.0.2000.0 $ROOTFS_DIR/usr/lib/libgio-2.0.so.0.2000.0 || error
    ln -sf libgio-2.0.so.0.2000.0 $ROOTFS_DIR/usr/lib/libgio-2.0.so.0
    ln -sf libgio-2.0.so.0.2000.0 $ROOTFS_DIR/usr/lib/libgio-2.0.so
    $STRIP $ROOTFS_DIR/usr/lib/libgio-2.0.so.0.2000.0

    $INSTALL -D -m 644 glib/.libs/libglib-2.0.so.0.2000.0 $ROOTFS_DIR/usr/lib/libglib-2.0.so.0.2000.0 || error
    ln -sf libglib-2.0.so.0.2000.0 $ROOTFS_DIR/usr/lib/libglib-2.0.so.0
    ln -sf libglib-2.0.so.0.2000.0 $ROOTFS_DIR/usr/lib/libglib-2.0.so
    $STRIP $ROOTFS_DIR/usr/lib/libglib-2.0.so.0.2000.0

    $INSTALL -D -m 644 gmodule/.libs/libgmodule-2.0.so.0.2000.0 $ROOTFS_DIR/usr/lib/libgmodule-2.0.so.0.2000.0 || error
    ln -sf libgmodule-2.0.so.0.2000.0 $ROOTFS_DIR/usr/lib/libgmodule-2.0.so.0
    ln -sf libgmodule-2.0.so.0.2000.0 $ROOTFS_DIR/usr/lib/libgmodule-2.0.so
    $STRIP $ROOTFS_DIR/usr/lib/libgmodule-2.0.so.0.2000.0
    
    $INSTALL -D -m 644 gobject/.libs/libgobject-2.0.so.0.2000.0 $ROOTFS_DIR/usr/lib/libgobject-2.0.so.0.2000.0 || error
    ln -sf libgobject-2.0.so.0.2000.0 $ROOTFS_DIR/usr/lib/libgobject-2.0.so.0
    ln -sf libgobject-2.0.so.0.2000.0 $ROOTFS_DIR/usr/lib/libgobject-2.0.so
    $STRIP $ROOTFS_DIR/usr/lib/libgobject-2.0.so.0.2000.0

    $INSTALL -D -m 644 gthread/.libs/libgthread-2.0.so.0.2000.0 $ROOTFS_DIR/usr/lib/libgthread-2.0.so.0.2000.0 || error
    ln -sf libgthread-2.0.so.0.2000.0 $ROOTFS_DIR/usr/lib/libgthread-2.0.so.0
    ln -sf libgthread-2.0.so.0.2000.0 $ROOTFS_DIR/usr/lib/libgthread-2.0.so
    $STRIP $ROOTFS_DIR/usr/lib/libgthread-2.0.so.0.2000.0

    popd
    touch "$STATE_DIR/glib2.installed"
}

build_glib2
