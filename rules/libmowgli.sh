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

LIBMOWGLI=libmowgli-0.7.0.tbz2
LIBMOWGLI_MIRROR=http://distfiles.atheme.org
LIBMOWGLI_DIR=$BUILD_DIR/libmowgli-0.7.0
LIBMOWGLI_ENV="$CROSS_ENV_AC"

build_libmowgli() {
    test -e "$STATE_DIR/libmowgli.installed" && return
    banner "Build libmowgli"
    download $LIBMOWGLI_MIRROR $LIBMOWGLI
    extract $LIBMOWGLI
    apply_patches $LIBMOWGLI_DIR $LIBMOWGLI
    pushd $TOP_DIR
    cd $LIBMOWGLI_DIR
    (
    eval \
	$CROSS_CONF_ENV \
	$LIBMOWGLI_ENV \
	./configure --build=$BUILD_ARCH --host=$TARGET_ARCH \
	    --prefix=/usr \
	    --sysconfdir=/etc \
	    || error
    ) || error "configure"
    
    make $MAKEARGS || error

    install_sysroot_files || error
    
    $INSTALL -D -m 644 src/libmowgli/libmowgli.so $ROOTFS_DIR/usr/lib/libmowgli.so.2.0.0 || error
    ln -sf libmowgli.so.2.0.0 $ROOTFS_DIR/usr/lib/libmowgli.so.2 || error
    ln -sf libmowgli.so.2.0.0 $ROOTFS_DIR/usr/lib/libmowgli.so || error
    $STRIP $ROOTFS_DIR/usr/lib/libmowgli.so.2.0.0 || error

    popd
    touch "$STATE_DIR/libmowgli.installed"
}

build_libmowgli
