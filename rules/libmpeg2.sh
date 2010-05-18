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

LIBMPEG2_VERSION=0.5.1
LIBMPEG2=libmpeg2-${LIBMPEG2_VERSION}.tar.gz
LIBMPEG2_MIRROR=http://libmpeg2.sourceforge.net/files
LIBMPEG2_DIR=$BUILD_DIR/libmpeg2-${LIBMPEG2_VERSION}
LIBMPEG2_ENV="$CROSS_ENV_AC"

build_libmpeg2() {
    test -e "$STATE_DIR/libmpeg2.installed" && return
    banner "Build libmpeg2"
    download $LIBMPEG2_MIRROR $LIBMPEG2
    extract $LIBMPEG2
    apply_patches $LIBMPEG2_DIR $LIBMPEG2
    pushd $TOP_DIR
    cd $LIBMPEG2_DIR
    (
    eval \
	$CROSS_CONF_ENV \
	$LIBMPEG2_ENV \
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
    touch "$STATE_DIR/libmpeg2.installed"
}

build_libmpeg2
