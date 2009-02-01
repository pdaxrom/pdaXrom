#
# host packet template
#
# Copyright (C) 2004 by Alexander Chukov <sash@pdaXrom.org>
#          
# See CREDITS for details about who has contributed to this project.
#
# For further information about the pdaXrom project and license conditions
# see the README file.
#

# previous version: 2.3.2

HOST_MPFR_VERSION=2.4.0
HOST_MPFR=mpfr-${HOST_MPFR_VERSION}.tar.bz2
HOST_MPFR_MIRROR=http://www.mpfr.org/mpfr-current
HOST_MPFR_DIR=$BUILD_DIR/mpfr-${HOST_MPFR_VERSION}
HOST_MPFR_ENV=

build_host_mpfr() {
    test -e "$STATE_DIR/host_mpfr-${HOST_MPFR_VERSION}" && return
    banner "Build $HOST_MPFR"
    download $HOST_MPFR_MIRROR $HOST_MPFR
    extract $HOST_MPFR
    apply_patches $HOST_MPFR_DIR $HOST_MPFR
    pushd $TOP_DIR
    cd $HOST_MPFR_DIR
    eval $HOST_MPFR_ENV \
	./configure --prefix=$HOST_BIN_DIR --disable-shared \
	    --with-gmp=$HOST_BIN_DIR || error
    make $MAKEARGS || error
    make install || error
    popd
    touch "$STATE_DIR/host_mpfr-${HOST_MPFR_VERSION}"
}

build_host_mpfr
