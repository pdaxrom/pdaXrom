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

LIBCANBERRA_VERSION=0.22
LIBCANBERRA=libcanberra-${LIBCANBERRA_VERSION}.tar.gz
LIBCANBERRA_MIRROR=http://0pointer.de/lennart/projects/libcanberra
LIBCANBERRA_DIR=$BUILD_DIR/libcanberra-${LIBCANBERRA_VERSION}
LIBCANBERRA_ENV="$CROSS_ENV_AC"

build_libcanberra() {
    test -e "$STATE_DIR/libcanberra.installed" && return
    banner "Build libcanberra"
    download $LIBCANBERRA_MIRROR $LIBCANBERRA
    extract $LIBCANBERRA
    apply_patches $LIBCANBERRA_DIR $LIBCANBERRA
    pushd $TOP_DIR
    cd $LIBCANBERRA_DIR
    (
    eval \
	$CROSS_CONF_ENV \
	$LIBCANBERRA_ENV \
	./configure --build=$BUILD_ARCH --host=$TARGET_ARCH \
	    --prefix=/usr \
	    --sysconfdir=/etc \
	    --disable-oss \
	    --disable-pulse \
	    || error
    ) || error "configure"

    make $MAKEARGS || error

    install_sysroot_files || error

    install_fakeroot_init
    rm -rf fakeroot/usr/share/gdm
    rm -rf fakeroot/usr/share/gnome
    rm -rf fakeroot/usr/share/vala
    install_fakeroot_finish || error

    popd
    touch "$STATE_DIR/libcanberra.installed"
}

build_libcanberra
