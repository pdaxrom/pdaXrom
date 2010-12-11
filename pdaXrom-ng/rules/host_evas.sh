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

HOST_EVAS_VERSION=1.0.0.beta3
HOST_EVAS=evas-${HOST_EVAS_VERSION}.tar.bz2
HOST_EVAS_MIRROR=http://download.enlightenment.org/releases
HOST_EVAS_DIR=$HOST_BUILD_DIR/evas-${HOST_EVAS_VERSION}
HOST_EVAS_ENV="PKG_CONFIG_PATH=${HOST_BIN_DIR}/lib/pkgconfig:/usr/lib/pkgconfig"

build_host_evas() {
    test -e "$STATE_DIR/host_evas.installed" && return
    banner "Build host-evas"
    download $HOST_EVAS_MIRROR $HOST_EVAS
    extract_host $HOST_EVAS
    apply_patches $HOST_EVAS_DIR $HOST_EVAS
    pushd $TOP_DIR
    cd $HOST_EVAS_DIR
    (
    eval $HOST_EVAS_ENV \
	./configure --prefix=$HOST_BIN_DIR
    ) || error
    make $MAKEARGS || error
    make $MAKEARGS install || error
    popd
    touch "$STATE_DIR/host_evas.installed"
}

build_host_evas
