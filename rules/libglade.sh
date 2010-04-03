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

LIBGLADE_VERSION=2.6.4
LIBGLADE=libglade-${LIBGLADE_VERSION}.tar.bz2
LIBGLADE_MIRROR=http://ftp.gnome.org/pub/GNOME/sources/libglade/2.6
LIBGLADE_DIR=$BUILD_DIR/libglade-${LIBGLADE_VERSION}
LIBGLADE_ENV="$CROSS_ENV_AC"

build_libglade() {
    test -e "$STATE_DIR/libglade.installed" && return
    banner "Build libglade"
    download $LIBGLADE_MIRROR $LIBGLADE
    extract $LIBGLADE
    apply_patches $LIBGLADE_DIR $LIBGLADE
    pushd $TOP_DIR
    cd $LIBGLADE_DIR
    (
    eval \
	$CROSS_CONF_ENV \
	$LIBGLADE_ENV \
	./configure --build=$BUILD_ARCH --host=$TARGET_ARCH \
	    --prefix=/usr \
	    --sysconfdir=/etc \
	    || error
    ) || error "configure"
    
    make $MAKEARGS || error

    install_sysroot_files || error
    
    $INSTALL -D -m 644 glade/.libs/libglade-2.0.so.0.0.7 $ROOTFS_DIR/usr/lib/libglade-2.0.so.0.0.7 || error
    ln -sf libglade-2.0.so.0.0.7 $ROOTFS_DIR/usr/lib/libglade-2.0.so.0
    ln -sf libglade-2.0.so.0.0.7 $ROOTFS_DIR/usr/lib/libglade-2.0.so
    $STRIP $ROOTFS_DIR/usr/lib/libglade-2.0.so.0.0.7 || error

    popd
    touch "$STATE_DIR/libglade.installed"
}

build_libglade
