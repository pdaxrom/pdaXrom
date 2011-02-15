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

LIBGPG_ERROR=libgpg-error-1.7.tar.bz2
LIBGPG_ERROR_MIRROR=ftp://ftp.gnupg.org/gcrypt/libgpg-error
LIBGPG_ERROR_DIR=$BUILD_DIR/libgpg-error-1.7
LIBGPG_ERROR_ENV="$CROSS_ENV_AC"

build_libgpg_error() {
    test -e "$STATE_DIR/libgpg_error.installed" && return
    banner "Build libgpg-error"
    download $LIBGPG_ERROR_MIRROR $LIBGPG_ERROR
    extract $LIBGPG_ERROR
    apply_patches $LIBGPG_ERROR_DIR $LIBGPG_ERROR
    pushd $TOP_DIR
    cd $LIBGPG_ERROR_DIR
    (
    eval \
	$CROSS_CONF_ENV \
	$LIBGPG_ERROR_ENV \
	./configure --build=$BUILD_ARCH --host=$TARGET_ARCH \
	    --prefix=/usr \
	    --sysconfdir=/etc \
	    || error
    ) || error "configure"
    
    make $MAKEARGS || error

    install_sysroot_files || error
    
    ln -sf $TARGET_BIN_DIR/bin/gpg-error-config $HOST_BIN_DIR/bin/ || error
    
    $INSTALL -D -m 644 src/.libs/libgpg-error.so.0.5.0 $ROOTFS_DIR/usr/lib/libgpg-error.so.0.5.0 || error
    ln -sf libgpg-error.so.0.5.0 $ROOTFS_DIR/usr/lib/libgpg-error.so.0
    ln -sf libgpg-error.so.0.5.0 $ROOTFS_DIR/usr/lib/libgpg-error.so
    $STRIP $ROOTFS_DIR/usr/lib/libgpg-error.so.0.5.0

    popd
    touch "$STATE_DIR/libgpg_error.installed"
}

build_libgpg_error
