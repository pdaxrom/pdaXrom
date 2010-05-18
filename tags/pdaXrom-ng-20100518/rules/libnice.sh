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

LIBNICE_VERSION=0.0.9
LIBNICE=libnice-${LIBNICE_VERSION}.tar.gz
LIBNICE_MIRROR=http://nice.freedesktop.org/releases
LIBNICE_DIR=$BUILD_DIR/libnice-${LIBNICE_VERSION}
LIBNICE_ENV="$CROSS_ENV_AC"

build_libnice() {
    test -e "$STATE_DIR/libnice.installed" && return
    banner "Build libnice"
    download $LIBNICE_MIRROR $LIBNICE
    extract $LIBNICE
    apply_patches $LIBNICE_DIR $LIBNICE
    pushd $TOP_DIR
    cd $LIBNICE_DIR
    (
    eval \
	$CROSS_CONF_ENV \
	$LIBNICE_ENV \
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
    touch "$STATE_DIR/libnice.installed"
}

build_libnice
