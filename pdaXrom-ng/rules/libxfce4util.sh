#
# packet template
#
# Copyright (C) 2010 by Alexander Chukov <sash@pdaXrom.org>
#
# See CREDITS for details about who has contributed to this project.
#
# For further information about the pdaXrom project and license conditions
# see the README file.
#

LIBXFCE4UTIL_VERSION=4.7.4
LIBXFCE4UTIL=libxfce4util-${LIBXFCE4UTIL_VERSION}.tar.bz2
LIBXFCE4UTIL_MIRROR=http://mocha.xfce.org/archive/xfce/4.8pre2/src
LIBXFCE4UTIL_DIR=$BUILD_DIR/libxfce4util-${LIBXFCE4UTIL_VERSION}
LIBXFCE4UTIL_ENV="$CROSS_ENV_AC"

build_libxfce4util() {
    test -e "$STATE_DIR/libxfce4util.installed" && return
    banner "Build libxfce4util"
    download $LIBXFCE4UTIL_MIRROR $LIBXFCE4UTIL
    extract $LIBXFCE4UTIL
    apply_patches $LIBXFCE4UTIL_DIR $LIBXFCE4UTIL
    pushd $TOP_DIR
    cd $LIBXFCE4UTIL_DIR
    (
    eval \
	$CROSS_CONF_ENV \
	$LIBXFCE4UTIL_ENV \
	./configure --build=$BUILD_ARCH --host=$TARGET_ARCH \
	    --prefix=/usr \
	    --sysconfdir=/etc \
	    --with-broken-putenv=no \
	    || error
    ) || error "configure"

    make $MAKEARGS || error

    install_sysroot_files || error

    install_fakeroot_init

    install_fakeroot_finish || error

    popd
    touch "$STATE_DIR/libxfce4util.installed"
}

build_libxfce4util
