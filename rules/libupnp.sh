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

LIBUPNP_VERSION=1.6.6
LIBUPNP=libupnp-${LIBUPNP_VERSION}.tar.bz2
LIBUPNP_MIRROR=http://downloads.sourceforge.net/project/pupnp/pupnp/LibUPnP%201.6.6
LIBUPNP_DIR=$BUILD_DIR/libupnp-${LIBUPNP_VERSION}
LIBUPNP_ENV="$CROSS_ENV_AC"

build_libupnp() {
    test -e "$STATE_DIR/libupnp.installed" && return
    banner "Build libupnp"
    download $LIBUPNP_MIRROR $LIBUPNP
    extract $LIBUPNP
    apply_patches $LIBUPNP_DIR $LIBUPNP
    pushd $TOP_DIR
    cd $LIBUPNP_DIR
    (
    eval \
	$CROSS_CONF_ENV \
	$LIBUPNP_ENV \
	./configure --build=$BUILD_ARCH --host=$TARGET_ARCH \
	    --prefix=/usr \
	    --sysconfdir=/etc \
	    || error
    ) || error "configure"

    make $MAKEARGS || error

    install_sysroot_files || error

    install_fakeroot_init
    install_fakeroot_finish || error

    popd
    touch "$STATE_DIR/libupnp.installed"
}

build_libupnp
