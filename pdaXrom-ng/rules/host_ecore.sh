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

HOST_ECORE_VERSION=1.0.0.beta3
HOST_ECORE=ecore-${HOST_ECORE_VERSION}.tar.bz2
HOST_ECORE_MIRROR=http://download.enlightenment.org/releases
HOST_ECORE_DIR=$HOST_BUILD_DIR/ecore-${HOST_ECORE_VERSION}
HOST_ECORE_ENV="PKG_CONFIG_PATH=${HOST_BIN_DIR}/lib/pkgconfig:/usr/lib/pkgconfig"

build_host_ecore() {
    test -e "$STATE_DIR/host_ecore.installed" && return
    banner "Build host-ecore"
    download $HOST_ECORE_MIRROR $HOST_ECORE
    extract_host $HOST_ECORE
    apply_patches $HOST_ECORE_DIR $HOST_ECORE
    pushd $TOP_DIR
    cd $HOST_ECORE_DIR
    (
    eval $HOST_ECORE_ENV \
	./configure --prefix=$HOST_BIN_DIR
    ) || error
    make $MAKEARGS || error
    make $MAKEARGS install || error
    popd
    touch "$STATE_DIR/host_ecore.installed"
}

build_host_ecore
