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

LIBPROXY_VERSION=0.3.1
LIBPROXY=libproxy-${LIBPROXY_VERSION}.tar.bz2
LIBPROXY_MIRROR=http://libproxy.googlecode.com/files
LIBPROXY_DIR=$BUILD_DIR/libproxy-${LIBPROXY_VERSION}
LIBPROXY_ENV="$CROSS_ENV_AC"

build_libproxy() {
    test -e "$STATE_DIR/libproxy.installed" && return
    banner "Build libproxy"
    download $LIBPROXY_MIRROR $LIBPROXY
    extract $LIBPROXY
    apply_patches $LIBPROXY_DIR $LIBPROXY
    pushd $TOP_DIR
    cd $LIBPROXY_DIR
    (
    eval \
	$CROSS_CONF_ENV \
	$LIBPROXY_ENV \
	./configure --build=$BUILD_ARCH --host=$TARGET_ARCH \
	    --prefix=/usr \
	    --sysconfdir=/etc \
	    --without-python \
	    --without-dotnet \
	    --without-gnome \
	    --without-kde4 \
	    --without-wpad \
	    --without-networkmanager \
	    || error
    ) || error "configure"

    make $MAKEARGS || error

    install_sysroot_files || error

    install_fakeroot_init
    install_fakeroot_finish || error

    popd
    touch "$STATE_DIR/libproxy.installed"
}

build_libproxy
