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

LIBMD_VERSION=0.3
LIBMD=libmd-${LIBMD_VERSION}.tar.bz2
LIBMD_MIRROR=ftp://ftp.penguin.cz/pub/users/mhi/libmd
LIBMD_DIR=$BUILD_DIR/libmd-${LIBMD_VERSION}
LIBMD_ENV="$CROSS_ENV_AC"

build_libmd() {
    test -e "$STATE_DIR/libmd.installed" && return
    banner "Build libmd"
    download $LIBMD_MIRROR $LIBMD
    extract $LIBMD
    apply_patches $LIBMD_DIR $LIBMD
    pushd $TOP_DIR
    cd $LIBMD_DIR
    (
    eval \
	$CROSS_CONF_ENV \
	$LIBMD_ENV \
	./configure --build=$BUILD_ARCH --host=$TARGET_ARCH \
	    --prefix=/usr \
	    --sysconfdir=/etc \
	    || error
    ) || error "configure"
    
    make $MAKEARGS CC=${CROSS}gcc AR=${CROSS}ar RANLIB=${CROSS}ranlib || error

    install_sysroot_files || error

    $INSTALL -D -m 644 libmd.so.1.0 $ROOTFS_DIR/usr/lib/libmd.so.1.0 || error
    ln -sf libmd.so.1.0 $ROOTFS_DIR/usr/lib/libmd.so.1
    ln -sf libmd.so.1.0 $ROOTFS_DIR/usr/lib/libmd.so
    $STRIP $ROOTFS_DIR/usr/lib/libmd.so.1.0 || error

    popd
    touch "$STATE_DIR/libmd.installed"
}

build_libmd
