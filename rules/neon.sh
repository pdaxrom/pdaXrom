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

NEON=neon-0.28.3.tar.gz
NEON_MIRROR=http://www.webdav.org/neon
NEON_DIR=$BUILD_DIR/neon-0.28.3
NEON_ENV="$CROSS_ENV_AC ne_cv_os_uname=Linux"

build_neon() {
    test -e "$STATE_DIR/neon.installed" && return
    banner "Build neon"
    download $NEON_MIRROR $NEON
    extract $NEON
    apply_patches $NEON_DIR $NEON
    pushd $TOP_DIR
    cd $NEON_DIR
    (
    eval \
	$CROSS_CONF_ENV \
	$NEON_ENV \
	./configure --build=$BUILD_ARCH --host=$TARGET_ARCH \
	    --prefix=/usr \
	    --sysconfdir=/etc \
	    --enable-shared \
	    --with-libxml2 \
	    --with-ssl=openssl \
	    || error
    ) || error "configure"
    
    make $MAKEARGS || error

    install_sysroot_files || error
    
    $INSTALL -D -m 644 src/.libs/libneon.so.27.1.3 $ROOTFS_DIR/usr/lib/libneon.so.27.1.3 || error
    ln -sf libneon.so.27.1.3 $ROOTFS_DIR/usr/lib/libneon.so.27
    ln -sf libneon.so.27.1.3 $ROOTFS_DIR/usr/lib/libneon.so
    $STRIP $ROOTFS_DIR/usr/lib/libneon.so.27.1.3 || error

    ln -sf $TARGET_BIN_DIR/bin/neon-config $HOST_BIN_DIR/bin/neon-config || error

    popd
    touch "$STATE_DIR/neon.installed"
}

build_neon
