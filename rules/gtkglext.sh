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

GTKGLEXT_VERSION=1.2.0
GTKGLEXT=gtkglext-${GTKGLEXT_VERSION}.tar.gz
GTKGLEXT_MIRROR=http://downloads.sourceforge.net/gtkglext
GTKGLEXT_DIR=$BUILD_DIR/gtkglext-${GTKGLEXT_VERSION}
GTKGLEXT_ENV="$CROSS_ENV_AC"

build_gtkglext() {
    test -e "$STATE_DIR/gtkglext.installed" && return
    banner "Build gtkglext"
    download $GTKGLEXT_MIRROR $GTKGLEXT
    extract $GTKGLEXT
    apply_patches $GTKGLEXT_DIR $GTKGLEXT
    pushd $TOP_DIR
    cd $GTKGLEXT_DIR
    (
    eval \
	$CROSS_CONF_ENV \
	$GTKGLEXT_ENV \
	./configure --build=$BUILD_ARCH --host=$TARGET_ARCH \
	    --prefix=/usr \
	    --sysconfdir=/etc \
	    --enable-debug=no \
	    || error
    ) || error "configure"
    
    make $MAKEARGS || error

    install_sysroot_files || error
    
    $INSTALL -D -m 644 gdk/.libs/libgdkglext-x11-1.0.so.0.0.0 $ROOTFS_DIR/usr/lib/libgdkglext-x11-1.0.so.0.0.0 || error
    ln -sf libgdkglext-x11-1.0.so.0.0.0 $ROOTFS_DIR/usr/lib/libgdkglext-x11-1.0.so.0
    ln -sf libgdkglext-x11-1.0.so.0.0.0 $ROOTFS_DIR/usr/lib/libgdkglext-x11-1.0.so
    $STRIP $ROOTFS_DIR/usr/lib/libgdkglext-x11-1.0.so.0.0.0 || error

    $INSTALL -D -m 644 gtk/.libs/libgtkglext-x11-1.0.so.0.0.0 $ROOTFS_DIR/usr/lib/libgtkglext-x11-1.0.so.0.0.0 || error
    ln -sf libgtkglext-x11-1.0.so.0.0.0 $ROOTFS_DIR/usr/lib/libgtkglext-x11-1.0.so.0
    ln -sf libgtkglext-x11-1.0.so.0.0.0 $ROOTFS_DIR/usr/lib/libgtkglext-x11-1.0.so
    $STRIP $ROOTFS_DIR/usr/lib/libgtkglext-x11-1.0.so.0.0.0 || error

    popd
    touch "$STATE_DIR/gtkglext.installed"
}

build_gtkglext
