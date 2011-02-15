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

LIBWV=wv-1.2.4.tar.gz
LIBWV_MIRROR=http://downloads.sourceforge.net/wvware
LIBWV_DIR=$BUILD_DIR/wv-1.2.4
LIBWV_ENV="$CROSS_ENV_AC"

build_libwv() {
    test -e "$STATE_DIR/libwv.installed" && return
    banner "Build libwv"
    download $LIBWV_MIRROR $LIBWV
    extract $LIBWV
    apply_patches $LIBWV_DIR $LIBWV
    pushd $TOP_DIR
    cd $LIBWV_DIR
    (
    eval \
	$CROSS_CONF_ENV \
	$LIBWV_ENV \
	./configure --build=$BUILD_ARCH --host=$TARGET_ARCH \
	    --prefix=/usr \
	    --sysconfdir=/etc \
	    || error
    ) || error "configure"
    
    make $MAKEARGS || error

    install_sysroot_files || error
    
    $INSTALL -D -m 644 .libs/libwv-1.2.so.3.0.1 $ROOTFS_DIR/usr/lib/libwv-1.2.so.3.0.1 || error
    ln -sf libwv-1.2.so.3.0.1 $ROOTFS_DIR/usr/lib/libwv-1.2.so.3
    ln -sf libwv-1.2.so.3.0.1 $ROOTFS_DIR/usr/lib/libwv-1.2.so
    $STRIP $ROOTFS_DIR/usr/lib/libwv-1.2.so.3.0.1

    popd
    touch "$STATE_DIR/libwv.installed"
}

build_libwv
