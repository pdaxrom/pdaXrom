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

LIBSEXY=libsexy-0.1.11.tar.gz
LIBSEXY_MIRROR=http://releases.chipx86.com/libsexy/libsexy
LIBSEXY_DIR=$BUILD_DIR/libsexy-0.1.11
LIBSEXY_ENV="$CROSS_ENV_AC"

build_libsexy() {
    test -e "$STATE_DIR/libsexy.installed" && return
    banner "Build libsexy"
    download $LIBSEXY_MIRROR $LIBSEXY
    extract $LIBSEXY
    apply_patches $LIBSEXY_DIR $LIBSEXY
    pushd $TOP_DIR
    cd $LIBSEXY_DIR
    (
    eval \
	$CROSS_CONF_ENV \
	$LIBSEXY_ENV \
	./configure --build=$BUILD_ARCH --host=$TARGET_ARCH \
	    --prefix=/usr \
	    --sysconfdir=/etc \
	    || error
    ) || error "configure"
    
    make $MAKEARGS || error

    install_sysroot_files || error
    
    $INSTALL -D -m 644 libsexy/.libs/libsexy.so.2.0.4 $ROOTFS_DIR/usr/lib/libsexy.so.2.0.4 || error
    ln -sf libsexy.so.2.0.4 $ROOTFS_DIR/usr/lib/libsexy.so.2
    ln -sf libsexy.so.2.0.4 $ROOTFS_DIR/usr/lib/libsexy.so
    $STRIP $ROOTFS_DIR/usr/lib/libsexy.so.2.0.4

    popd
    touch "$STATE_DIR/libsexy.installed"
}

build_libsexy
