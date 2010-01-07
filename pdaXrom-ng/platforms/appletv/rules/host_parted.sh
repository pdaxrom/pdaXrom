#
# host packet template
#
# Copyright (C) 2009 by Alexander Chukov <sash@pdaXrom.org>
#
# See CREDITS for details about who has contributed to this project.
#
# For further information about the pdaXrom project and license conditions
# see the README file.
#

HOST_PARTED_VERSION=1.8.8
HOST_PARTED=parted-${HOST_PARTED_VERSION}.tar.gz
HOST_PARTED_MIRROR=http://ftp.gnu.org/gnu/parted
HOST_PARTED_DIR=$HOST_BUILD_DIR/parted-${HOST_PARTED_VERSION}
HOST_PARTED_ENV="CFLAGS='-O2 -I${HOST_BIN_DIR}/include' LDFLAGS='-L${HOST_BIN_DIR}/lib'"

build_host_parted() {
    test -e "$STATE_DIR/host_parted.installed" && return
    banner "Build host-parted"
    download $HOST_PARTED_MIRROR $HOST_PARTED
    extract_host $HOST_PARTED
    echo ">>> $PWD"
    apply_patches $HOST_PARTED_DIR $HOST_PARTED
    pushd $TOP_DIR
    cd $HOST_PARTED_DIR
    (
    eval $HOST_PARTED_ENV \
	./configure --prefix=$HOST_BIN_DIR \
	    --enable-static \
	    --disable-shared \
	    --disable-device-mapper \
	    --without-readline \
	    --disable-Werror \
	    || error "configure"
    ) || error
    make $MAKEARGS || error "build"
    make $MAKEARGS install || error "install"
    popd
    touch "$STATE_DIR/host_parted.installed"
}

build_host_parted
