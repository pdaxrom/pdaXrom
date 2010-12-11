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

HOST_EMBRYO_VERSION=1.0.0.beta3
HOST_EMBRYO=embryo-${HOST_EMBRYO_VERSION}.tar.bz2
HOST_EMBRYO_MIRROR=http://download.enlightenment.org/releases
HOST_EMBRYO_DIR=$HOST_BUILD_DIR/embryo-${HOST_EMBRYO_VERSION}
HOST_EMBRYO_ENV="PKG_CONFIG_PATH=${HOST_BIN_DIR}/lib/pkgconfig"

build_host_embryo() {
    test -e "$STATE_DIR/host_embryo.installed" && return
    banner "Build host-embryo"
    download $HOST_EMBRYO_MIRROR $HOST_EMBRYO
    extract_host $HOST_EMBRYO
    apply_patches $HOST_EMBRYO_DIR $HOST_EMBRYO
    pushd $TOP_DIR
    cd $HOST_EMBRYO_DIR
    (
    eval $HOST_EMBRYO_ENV \
	./configure --prefix=$HOST_BIN_DIR
    ) || error
    make $MAKEARGS || error
    make $MAKEARGS install || error
    rm -f ${TARGET_BIN_DIR}/bin/embryo_cc
    ln -sf ${HOST_BIN_DIR}/bin/embryo_cc ${TARGET_BIN_DIR}/bin/embryo_cc || error "symlink to host embryo_cc"
    popd
    touch "$STATE_DIR/host_embryo.installed"
}

build_host_embryo
