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

LIBGD_VERSION=2.0.36RC1
LIBGD=gd-${LIBGD_VERSION}.tar.bz2
LIBGD_MIRROR=http://www.libgd.org/releases
LIBGD_DIR=$BUILD_DIR/gd-${LIBGD_VERSION}
LIBGD_ENV="$CROSS_ENV_AC"

build_libgd() {
    test -e "$STATE_DIR/libgd.installed" && return
    banner "Build libgd"
    download $LIBGD_MIRROR $LIBGD
    extract $LIBGD
    apply_patches $LIBGD_DIR $LIBGD
    pushd $TOP_DIR
    cd $LIBGD_DIR
    (
    eval \
	$CROSS_CONF_ENV \
	$LIBGD_ENV \
	./configure --build=$BUILD_ARCH --host=$TARGET_ARCH \
	    --prefix=/usr \
	    --sysconfdir=/etc \
	    || error
    ) || error "configure"

    make $MAKEARGS || error

    install_sysroot_files || error

    install_fakeroot_init

    error "update install"

    install_fakeroot_finish || error

    popd
    touch "$STATE_DIR/libgd.installed"
}

build_libgd
