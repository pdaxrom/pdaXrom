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

HOST_GMP_VERSION=4.2.4
HOST_GMP=gmp-${HOST_GMP_VERSION}.tar.bz2
HOST_GMP_MIRROR=ftp://ftp.gnu.org/gnu/gmp
HOST_GMP_DIR=$BUILD_DIR/gmp-${HOST_GMP_VERSION}

if [ $HOST_SYSTEM = "Darwin" ]; then
    if [ "${BUILD_ARCH/-*}" = "x86_64" -o "${BUILD_ARCH/-*}" = "amd64" ]; then
	HOST_GMP_ENV="ABI=64"
    else
	HOST_GMP_ENV="ABI=32"
    fi
fi

build_host_gmp() {
    test -e "$STATE_DIR/host_gmp-${HOST_GMP_VERSION}" && return
    banner "Build $HOST_GMP"
    download $HOST_GMP_MIRROR $HOST_GMP
    extract $HOST_GMP
    apply_patches $HOST_GMP_DIR $HOST_GMP
    pushd $TOP_DIR
    cd $HOST_GMP_DIR
    eval $HOST_GMP_ENV \
    ./configure --prefix=$HOST_BIN_DIR --disable-shared --enable-cxx || error
    make $MAKEARGS || error
    make install || error
    popd
    touch "$STATE_DIR/host_gmp-${HOST_GMP_VERSION}"
}

build_host_gmp
