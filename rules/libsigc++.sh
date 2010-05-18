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

LIBSIGCPP_VERSION=2.2.3
LIBSIGCPP=libsigc++-${LIBSIGCPP_VERSION}.tar.bz2
LIBSIGCPP_MIRROR=http://ftp.gnome.org/pub/GNOME/sources/libsigc++/2.2
LIBSIGCPP_DIR=$BUILD_DIR/libsigc++-${LIBSIGCPP_VERSION}
LIBSIGCPP_ENV="$CROSS_ENV_AC"

build_libsigc++() {
    test -e "$STATE_DIR/libsigc++.installed" && return
    banner "Build libsigc++"
    download $LIBSIGCPP_MIRROR $LIBSIGCPP
    extract $LIBSIGCPP
    apply_patches $LIBSIGCPP_DIR $LIBSIGCPP
    pushd $TOP_DIR
    cd $LIBSIGCPP_DIR
    (
    eval \
	$CROSS_CONF_ENV \
	$LIBSIGCPP_ENV \
	./configure --build=$BUILD_ARCH --host=$TARGET_ARCH \
	    --prefix=/usr \
	    --sysconfdir=/etc \
	    || error
    ) || error "configure"
    
    make $MAKEARGS || error

    install_sysroot_files || error
    
    install_rootfs_usr_lib sigc++/.libs/libsigc-2.0.so.0.0.0

    popd
    touch "$STATE_DIR/libsigc++.installed"
}

build_libsigc++
