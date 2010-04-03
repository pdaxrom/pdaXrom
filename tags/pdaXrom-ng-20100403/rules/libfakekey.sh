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

LIBFAKEKEY_VERSION=0.1
LIBFAKEKEY=libfakekey-${LIBFAKEKEY_VERSION}.tar.bz2
LIBFAKEKEY_MIRROR=http://matchbox-project.org/sources/libfakekey/0.1
LIBFAKEKEY_DIR=$BUILD_DIR/libfakekey-${LIBFAKEKEY_VERSION}
LIBFAKEKEY_ENV="$CROSS_ENV_AC"

build_libfakekey() {
    test -e "$STATE_DIR/libfakekey.installed" && return
    banner "Build libfakekey"
    download $LIBFAKEKEY_MIRROR $LIBFAKEKEY
    extract $LIBFAKEKEY
    apply_patches $LIBFAKEKEY_DIR $LIBFAKEKEY
    pushd $TOP_DIR
    cd $LIBFAKEKEY_DIR
    (
    eval \
	$CROSS_CONF_ENV \
	$LIBFAKEKEY_ENV \
	./configure --build=$BUILD_ARCH --host=$TARGET_ARCH \
	    --prefix=/usr \
	    --sysconfdir=/etc \
	    || error
    ) || error "configure"
    
    make $MAKEARGS || error

    install_sysroot_files || error

    $INSTALL -D -m 644 src/.libs/libfakekey.so.0.0.1 $ROOTFS_DIR/usr/lib/libfakekey.so.0.0.1 || error
    ln -sf libfakekey.so.0.0.1 $ROOTFS_DIR/usr/lib/libfakekey.so.0 || error
    ln -sf libfakekey.so.0.0.1 $ROOTFS_DIR/usr/lib/libfakekey.so || error
    $STRIP $ROOTFS_DIR/usr/lib/libfakekey.so.0.0.1 || error

    popd
    touch "$STATE_DIR/libfakekey.installed"
}

build_libfakekey
