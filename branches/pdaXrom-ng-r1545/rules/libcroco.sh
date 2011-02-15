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

LIBCROCO_VERSION=0.6.1
LIBCROCO=libcroco-${LIBCROCO_VERSION}.tar.bz2
LIBCROCO_MIRROR=http://ftp.gnome.org/pub/GNOME/sources/libcroco/0.6
LIBCROCO_DIR=$BUILD_DIR/libcroco-${LIBCROCO_VERSION}
LIBCROCO_ENV="$CROSS_ENV_AC"

build_libcroco() {
    test -e "$STATE_DIR/libcroco.installed" && return
    banner "Build libcroco"
    download $LIBCROCO_MIRROR $LIBCROCO
    extract $LIBCROCO
    apply_patches $LIBCROCO_DIR $LIBCROCO
    pushd $TOP_DIR
    cd $LIBCROCO_DIR
    (
    eval \
	$CROSS_CONF_ENV \
	$LIBCROCO_ENV \
	./configure --build=$BUILD_ARCH --host=$TARGET_ARCH \
	    --prefix=/usr \
	    --sysconfdir=/etc \
	    || error
    ) || error "configure"
    
    make $MAKEARGS || error

    install_sysroot_files || error

    $INSTALL -D -m 644 src/.libs/libcroco-0.6.so.3.0.1 $ROOTFS_DIR/usr/lib/libcroco-0.6.so.3.0.1 || error
    ln -sf libcroco-0.6.so.3.0.1 $ROOTFS_DIR/usr/lib/libcroco-0.6.so.3
    ln -sf libcroco-0.6.so.3.0.1 $ROOTFS_DIR/usr/lib/libcroco-0.6.so
    $STRIP $ROOTFS_DIR/usr/lib/libcroco-0.6.so.3.0.1

    popd
    touch "$STATE_DIR/libcroco.installed"
}

build_libcroco
