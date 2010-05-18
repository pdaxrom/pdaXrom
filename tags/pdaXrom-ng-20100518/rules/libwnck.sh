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

LIBWNCK_VERSION=2.28.0
LIBWNCK=libwnck-${LIBWNCK_VERSION}.tar.bz2
LIBWNCK_MIRROR=http://ftp.gnome.org/pub/GNOME/sources/libwnck/2.28
LIBWNCK_DIR=$BUILD_DIR/libwnck-${LIBWNCK_VERSION}
LIBWNCK_ENV="$CROSS_ENV_AC"

build_libwnck() {
    test -e "$STATE_DIR/libwnck.installed" && return
    banner "Build libwnck"
    download $LIBWNCK_MIRROR $LIBWNCK
    extract $LIBWNCK
    apply_patches $LIBWNCK_DIR $LIBWNCK
    pushd $TOP_DIR
    cd $LIBWNCK_DIR
    (
    eval \
	$CROSS_CONF_ENV \
	$LIBWNCK_ENV \
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
    touch "$STATE_DIR/libwnck.installed"
}

build_libwnck
