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

ALSA_LIB_VERSION=1.0.23
ALSA_LIB=alsa-lib-${ALSA_LIB_VERSION}.tar.bz2
ALSA_LIB_MIRROR=ftp://ftp.alsa-project.org/pub/lib
ALSA_LIB_DIR=$BUILD_DIR/alsa-lib-${ALSA_LIB_VERSION}
ALSA_LIB_ENV=

build_alsa_lib() {
    test -e "$STATE_DIR/alsa_lib-${ALSA_LIB_VERSION}" && return
    banner "Build $ALSA_LIB"
    download $ALSA_LIB_MIRROR $ALSA_LIB
    extract $ALSA_LIB
    apply_patches $ALSA_LIB_DIR $ALSA_LIB
    pushd $TOP_DIR
    cd $ALSA_LIB_DIR
    local C_ARGS=
    case $TARGET_ARCH in
    *uclibc*)
	C_ARGS="--without-versioned"
	;;
    esac
    (
    eval \
	$CROSS_CONF_ENV \
	$ALSA_LIB_ENV \
	./configure --build=$BUILD_ARCH --host=$TARGET_ARCH \
	    --prefix=/usr \
	    --sysconfdir=/etc \
	     $C_ARGS \
	    --disable-python || error
    )
    make $MAKEARGS || error

    install_sysroot_files

    install_fakeroot_init
    install_fakeroot_finish || error

    popd
    touch "$STATE_DIR/alsa_lib-${ALSA_LIB_VERSION}"
}

build_alsa_lib
