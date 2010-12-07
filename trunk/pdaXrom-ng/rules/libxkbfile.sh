#
# packet template
#
# Copyright (C) 2008 by Alexander Chukov <sash@pdaXrom.org>
#          
# See CREDITS for details about who has contributed to this project.
#
# For further information about the pdaXrom project and license conditions
# see the README file.
#

LIBXKBFILE_VERSION=1.0.7
LIBXKBFILE=libxkbfile-${LIBXKBFILE_VERSION}.tar.bz2
LIBXKBFILE_MIRROR=ftp://ftp.freedesktop.org/pub/xorg/individual/lib
LIBXKBFILE_DIR=$BUILD_DIR/libxkbfile-${LIBXKBFILE_VERSION}
LIBXKBFILE_ENV=

build_libxkbfile() {
    test -e "$STATE_DIR/libxkbfile-${LIBXKBFILE_VERSION}" && return
    banner "Build $LIBXKBFILE"
    download $LIBXKBFILE_MIRROR $LIBXKBFILE
    extract $LIBXKBFILE
    apply_patches $LIBXKBFILE_DIR $LIBXKBFILE
    pushd $TOP_DIR
    cd $LIBXKBFILE_DIR
    (
    eval \
	$CROSS_CONF_ENV \
	$LIBXKBFILE_ENV \
	./configure --build=$BUILD_ARCH --host=$TARGET_ARCH \
	    --prefix=/usr \
	    --sysconfdir=/etc \
	    || error
    )
    make $MAKEARGS || error

    install_sysroot_files || error

    install_fakeroot_init
    install_fakeroot_finish || error

    popd
    touch "$STATE_DIR/libxkbfile-${LIBXKBFILE_VERSION}"
}

build_libxkbfile
