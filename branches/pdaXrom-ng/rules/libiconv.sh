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

LIBICONV_VERSION=1.12
LIBICONV=libiconv-${LIBICONV_VERSION}.tar.gz
LIBICONV_MIRROR=http://ftp.gnu.org/pub/gnu/libiconv
LIBICONV_DIR=$BUILD_DIR/libiconv-${LIBICONV_VERSION}
LIBICONV_ENV="$CROSS_ENV_AC"

build_libiconv() {
    test -e "$STATE_DIR/libiconv.installed" && return
    banner "Build libiconv"
    download $LIBICONV_MIRROR $LIBICONV
    extract $LIBICONV
    apply_patches $LIBICONV_DIR $LIBICONV
    pushd $TOP_DIR
    cd $LIBICONV_DIR
    (
    eval \
	$CROSS_CONF_ENV \
	$LIBICONV_ENV \
	./configure --build=$BUILD_ARCH --host=$TARGET_ARCH \
	    --prefix=/usr \
	    --sysconfdir=/etc \
	    || error
    ) || error "configure"
    
    make $MAKEARGS || error

    install_sysroot_files || error

    $INSTALL -D -m 644 lib/.libs/libiconv.so.2.4.0 $ROOTFS_DIR/usr/lib/libiconv.so.2.4.0 || error
    ln -sf $ROOTFS_DIR/usr/lib/libiconv.so.2.4.0 $ROOTFS_DIR/usr/lib/libiconv.so.2 || error
    ln -sf $ROOTFS_DIR/usr/lib/libiconv.so.2.4.0 $ROOTFS_DIR/usr/lib/libiconv.so || error
    $STRIP $ROOTFS_DIR/usr/lib/libiconv.so.2.4.0 || error
    
    $INSTALL -D -m 644 libcharset/lib/.libs/libcharset.so.1.0.0 $ROOTFS_DIR/usr/lib/libcharset.so.1.0.0 || error
    ln -sf $ROOTFS_DIR/usr/lib/libcharset.so.1.0.0 $ROOTFS_DIR/usr/lib/libcharset.so.1 || error
    ln -sf $ROOTFS_DIR/usr/lib/libcharset.so.1.0.0 $ROOTFS_DIR/usr/lib/libcharset.so || error
    $STRIP $ROOTFS_DIR/usr/lib/libcharset.so.1.0.0 || error

    popd
    touch "$STATE_DIR/libiconv.installed"
}

build_libiconv
