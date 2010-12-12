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

LIBFM_VERSION=0.1.14
LIBFM=libfm-${LIBFM_VERSION}.tar.gz
LIBFM_MIRROR=http://ovh.dl.sourceforge.net/project/pcmanfm/PCManFM%20%2B%20Libfm%20%28tarball%20release%29/libfm%20%28required%20by%20PCManFM%29
LIBFM_DIR=$BUILD_DIR/libfm-${LIBFM_VERSION}
LIBFM_ENV="$CROSS_ENV_AC LIBS=-Wl,-rpath,$LIBFM_DIR/src/.libs"

build_libfm() {
    test -e "$STATE_DIR/libfm.installed" && return
    banner "Build libfm"
    download $LIBFM_MIRROR $LIBFM
    extract $LIBFM
    apply_patches $LIBFM_DIR $LIBFM
    pushd $TOP_DIR
    cd $LIBFM_DIR
    autoreconf -i
    (
    eval \
	$CROSS_CONF_ENV \
	$LIBFM_ENV \
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
    touch "$STATE_DIR/libfm.installed"
}

build_libfm
