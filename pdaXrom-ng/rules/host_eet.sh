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

HOST_EET_VERSION=1.4.0.beta3
HOST_EET=eet-${HOST_EET_VERSION}.tar.bz2
HOST_EET_MIRROR=http://download.enlightenment.org/releases
HOST_EET_DIR=$HOST_BUILD_DIR/eet-${HOST_EET_VERSION}
HOST_EET_ENV="PKG_CONFIG_PATH=${HOST_BIN_DIR}/lib/pkgconfig"

build_host_eet() {
    test -e "$STATE_DIR/host_eet.installed" && return
    banner "Build host-eet"
    download $HOST_EET_MIRROR $HOST_EET
    extract_host $HOST_EET
    apply_patches $HOST_EET_DIR $HOST_EET
    pushd $TOP_DIR
    cd $HOST_EET_DIR
    (
    eval $HOST_EET_ENV \
	./configure --prefix=$HOST_BIN_DIR
    ) || error
    make $MAKEARGS || error
    make $MAKEARGS install || error
    rm -f ${TARGET_BIN_DIR}/bin/eet
    ln -sf ${HOST_BIN_DIR}/bin/eet ${TARGET_BIN_DIR}/bin/eet || error "symlink to host eet"
    popd
    touch "$STATE_DIR/host_eet.installed"
}

build_host_eet
