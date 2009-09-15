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

LIBGSF=libgsf-1.14.10.tar.bz2
LIBGSF_MIRROR=http://ftp.gnome.org/pub/gnome/sources/libgsf/1.14
LIBGSF_DIR=$BUILD_DIR/libgsf-1.14.10
LIBGSF_ENV="$CROSS_ENV_AC"

build_libgsf() {
    test -e "$STATE_DIR/libgsf.installed" && return
    banner "Build libgsf"
    download $LIBGSF_MIRROR $LIBGSF
    extract $LIBGSF
    apply_patches $LIBGSF_DIR $LIBGSF
    pushd $TOP_DIR
    cd $LIBGSF_DIR
    (
    eval \
	$CROSS_CONF_ENV \
	$LIBGSF_ENV \
	./configure --build=$BUILD_ARCH --host=$TARGET_ARCH \
	    --prefix=/usr \
	    --sysconfdir=/etc \
	    --without-python \
	    --without-gnome-vfs \
	    --without-bonobo \
	    || error
    ) || error "configure"
    
    make $MAKEARGS || error

    install_sysroot_files || error
    
    $INSTALL -D -m 644 gsf/.libs/libgsf-1.so.114.0.10 $ROOTFS_DIR/usr/lib/libgsf-1.so.114.0.10 || error
    ln -sf libgsf-1.so.114.0.10 $ROOTFS_DIR/usr/lib/libgsf-1.so.114
    ln -sf libgsf-1.so.114.0.10 $ROOTFS_DIR/usr/lib/libgsf-1.so
    $STRIP $ROOTFS_DIR/usr/lib/libgsf-1.so.114.0.10

    popd
    touch "$STATE_DIR/libgsf.installed"
}

build_libgsf
