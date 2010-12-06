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

LIBUNIQUE=unique-1.0.6.tar.gz
LIBUNIQUE_MIRROR=http://www.gnome.org/~ebassi/source
LIBUNIQUE_DIR=$BUILD_DIR/unique-1.0.6
LIBUNIQUE_ENV="$CROSS_ENV_AC"

build_libunique() {
    test -e "$STATE_DIR/libunique.installed" && return
    banner "Build libunique"
    download $LIBUNIQUE_MIRROR $LIBUNIQUE
    extract $LIBUNIQUE
    apply_patches $LIBUNIQUE_DIR $LIBUNIQUE
    pushd $TOP_DIR
    cd $LIBUNIQUE_DIR
    (
    eval \
	$CROSS_CONF_ENV \
	$LIBUNIQUE_ENV \
	./configure --build=$BUILD_ARCH --host=$TARGET_ARCH \
	    --prefix=/usr \
	    --sysconfdir=/etc \
	    || error
    ) || error "configure"
    
    make $MAKEARGS || error

    install_sysroot_files || error
    
    $INSTALL -D -m 644 unique/.libs/libunique-1.0.so.0.2.4 $ROOTFS_DIR/usr/lib/libunique-1.0.so.0.2.4 || error
    ln -sf libunique-1.0.so.0.2.4 $ROOTFS_DIR/usr/lib/libunique-1.0.so.0
    ln -sf libunique-1.0.so.0.2.4 $ROOTFS_DIR/usr/lib/libunique-1.0.so
    $STRIP $ROOTFS_DIR/usr/lib/libunique-1.0.so.0.2.4

    popd
    touch "$STATE_DIR/libunique.installed"
}

build_libunique
