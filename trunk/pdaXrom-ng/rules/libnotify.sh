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

LIBNOTIFY_VERSION=0.5.2
LIBNOTIFY=libnotify-${LIBNOTIFY_VERSION}.tar.bz2
LIBNOTIFY_MIRROR=http://ftp.acc.umu.se/pub/gnome/sources/libnotify/0.5
LIBNOTIFY_DIR=$BUILD_DIR/libnotify-${LIBNOTIFY_VERSION}
LIBNOTIFY_ENV="$CROSS_ENV_AC"

build_libnotify() {
    test -e "$STATE_DIR/libnotify.installed" && return
    banner "Build libnotify"
    download $LIBNOTIFY_MIRROR $LIBNOTIFY
    extract $LIBNOTIFY
    apply_patches $LIBNOTIFY_DIR $LIBNOTIFY
    pushd $TOP_DIR
    cd $LIBNOTIFY_DIR
    (
    eval \
	$CROSS_CONF_ENV \
	$LIBNOTIFY_ENV \
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
    touch "$STATE_DIR/libnotify.installed"
}

build_libnotify
