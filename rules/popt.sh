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

POPT=popt-1.14.tar.gz
POPT_MIRROR=http://rpm5.org/files/popt
POPT_DIR=$BUILD_DIR/popt-1.14
POPT_ENV="$CROSS_ENV_AC ac_cv_va_copy=C99"

build_popt() {
    test -e "$STATE_DIR/popt.installed" && return
    banner "Build popt"
    download $POPT_MIRROR $POPT
    extract $POPT
    apply_patches $POPT_DIR $POPT
    pushd $TOP_DIR
    cd $POPT_DIR
    (
    eval \
	$CROSS_CONF_ENV \
	$POPT_ENV \
	./configure --build=$BUILD_ARCH --host=$TARGET_ARCH \
	    --prefix=/usr \
	    --sysconfdir=/etc \
	    || error
    ) || error "configure"
    
    make $MAKEARGS || error

    install_sysroot_files || error
    
    $INSTALL -D -m 644 .libs/libpopt.so.0.0.0 $ROOTFS_DIR/usr/lib/libpopt.so.0.0.0 || error
    ln -sf libpopt.so.0.0.0 $ROOTFS_DIR/usr/lib/libpopt.so.0
    ln -sf libpopt.so.0.0.0 $ROOTFS_DIR/usr/lib/libpopt.so
    $STRIP $ROOTFS_DIR/usr/lib/libpopt.so.0.0.0 || error

    popd
    touch "$STATE_DIR/popt.installed"
}

build_popt
