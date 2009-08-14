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

LIBGCRYPT_VERSION=1.4.4
LIBGCRYPT=libgcrypt-${LIBGCRYPT_VERSION}.tar.bz2
LIBGCRYPT_MIRROR=ftp://ftp.gnupg.org/gcrypt/libgcrypt
LIBGCRYPT_DIR=$BUILD_DIR/libgcrypt-${LIBGCRYPT_VERSION}
LIBGCRYPT_ENV="$CROSS_ENV_AC ac_cv_sys_symbol_underscore=no"

build_libgcrypt() {
    test -e "$STATE_DIR/libgcrypt.installed" && return
    banner "Build libgcrypt"
    download $LIBGCRYPT_MIRROR $LIBGCRYPT
    extract $LIBGCRYPT
    apply_patches $LIBGCRYPT_DIR $LIBGCRYPT
    pushd $TOP_DIR
    cd $LIBGCRYPT_DIR
    (
    eval \
	$CROSS_CONF_ENV \
	$LIBGCRYPT_ENV \
	./configure --build=$BUILD_ARCH --host=$TARGET_ARCH \
	    --prefix=/usr \
	    --sysconfdir=/etc
    ) || error "configure"
    
    make $MAKEARGS || error

    install_sysroot_files || error
    
    ln -sf $TARGET_BIN_DIR/bin/libgcrypt-config $HOST_BIN_DIR/bin/ || error
    
    $INSTALL -D -m 644 src/.libs/libgcrypt.so.11.5.2 $ROOTFS_DIR/usr/lib/libgcrypt.so.11.5.2 || error
    ln -sf libgcrypt.so.11.5.2 $ROOTFS_DIR/usr/lib/libgcrypt.so.11
    ln -sf libgcrypt.so.11.5.2 $ROOTFS_DIR/usr/lib/libgcrypt.so
    $STRIP $ROOTFS_DIR/usr/lib/libgcrypt.so.11.5.2 || error

    popd
    touch "$STATE_DIR/libgcrypt.installed"
}

build_libgcrypt
