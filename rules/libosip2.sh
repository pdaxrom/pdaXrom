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

LIBOSIP2_VERSION=3.3.0
LIBOSIP2=libosip2-${LIBOSIP2_VERSION}.tar.gz
LIBOSIP2_MIRROR=http://ftp.gnu.org/gnu/osip
LIBOSIP2_DIR=$BUILD_DIR/libosip2-${LIBOSIP2_VERSION}
LIBOSIP2_ENV="$CROSS_ENV_AC"

build_libosip2() {
    test -e "$STATE_DIR/libosip2.installed" && return
    banner "Build libosip2"
    download $LIBOSIP2_MIRROR $LIBOSIP2
    extract $LIBOSIP2
    apply_patches $LIBOSIP2_DIR $LIBOSIP2
    pushd $TOP_DIR
    cd $LIBOSIP2_DIR
    (
    eval \
	$CROSS_CONF_ENV \
	$LIBOSIP2_ENV \
	./configure --build=$BUILD_ARCH --host=$TARGET_ARCH \
	    --prefix=/usr \
	    --sysconfdir=/etc \
	    || error
    ) || error "configure"
    
    make $MAKEARGS || error

    install_sysroot_files || error
    
    install_rootfs_usr_lib src/osip2/.libs/libosip2.so.4.2.0
    install_rootfs_usr_lib src/osipparser2/.libs/libosipparser2.so.4.2.0

    popd
    touch "$STATE_DIR/libosip2.installed"
}

build_libosip2
