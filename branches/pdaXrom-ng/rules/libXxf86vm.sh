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

LIBXXF86VM=libXxf86vm-1.0.1.tar.bz2
LIBXXF86VM_MIRROR=ftp://ftp.freedesktop.org/pub/xorg/X11R7.3/src/lib
LIBXXF86VM_DIR=$BUILD_DIR/libXxf86vm-1.0.1
LIBXXF86VM_ENV=

build_libXxf86vm() {
    test -e "$STATE_DIR/libXxf86vm-1.0.1" && return
    banner "Build $LIBXXF86VM"
    download $LIBXXF86VM_MIRROR $LIBXXF86VM
    extract $LIBXXF86VM
    apply_patches $LIBXXF86VM_DIR $LIBXXF86VM
    pushd $TOP_DIR
    cd $LIBXXF86VM_DIR
    (
    eval \
	$CROSS_CONF_ENV \
	$LIBXXF86VM_ENV \
	./configure --host=$TARGET_ARCH \
	    --prefix=/usr \
	    --sysconfdir=/etc \
	    --disable-malloc0returnsnull \
	    || error
    )
    make $MAKEARGS || error

    install_sysroot_files || error
    
    $INSTALL -D -m 644 src/.libs/libXxf86vm.so.1.0.0 $ROOTFS_DIR/usr/lib/libXxf86vm.so.1.0.0 || error
    ln -sf libXxf86vm.so.1.0.0 $ROOTFS_DIR/usr/lib/libXxf86vm.so.1
    ln -sf libXxf86vm.so.1.0.0 $ROOTFS_DIR/usr/lib/libXxf86vm.so
    $STRIP $ROOTFS_DIR/usr/lib/libXxf86vm.so.1.0.0

    popd
    touch "$STATE_DIR/libXxf86vm-1.0.1"
}

build_libXxf86vm
