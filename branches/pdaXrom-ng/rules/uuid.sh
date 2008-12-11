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

UUID=uuid-1.6.2.tar.gz
UUID_MIRROR=ftp://ftp.ossp.org/pkg/lib/uuid
UUID_DIR=$BUILD_DIR/uuid-1.6.2
UUID_ENV="ac_cv_va_copy=C99"

build_uuid() {
    test -e "$STATE_DIR/uuid-1.6.2" && return
    banner "Build $UUID"
    download $UUID_MIRROR $UUID
    extract $UUID
    apply_patches $UUID_DIR $UUID
    pushd $TOP_DIR
    cd $UUID_DIR
    (
    eval \
	$CROSS_CONF_ENV \
	$UUID_ENV \
	./configure --host=$TARGET_ARCH \
	    --prefix=/usr \
	    --sysconfdir=/etc \
	    --without-perl \
	    --without-php \
	    --without-pgsql \
	    || error
    )
    make $MAKEARGS || error

    install_sysroot_files || error

    $INSTALL -D -m 644 .libs/libuuid.so.16.0.22 $ROOTFS_DIR/usr/lib/libuuid.so.16.0.22 || error
    ln -sf libuuid.so.16.0.22 $ROOTFS_DIR/usr/lib/libuuid.so.16
    ln -sf libuuid.so.16.0.22 $ROOTFS_DIR/usr/lib/libuuid.so
    $STRIP $ROOTFS_DIR/usr/lib/libuuid.so.16.0.22

    popd
    touch "$STATE_DIR/uuid-1.6.2"
}

build_uuid
