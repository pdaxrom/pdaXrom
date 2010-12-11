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

HOST_EINA_VERSION=1.0.0.beta3
HOST_EINA=eina-${HOST_EINA_VERSION}.tar.bz2
HOST_EINA_MIRROR=http://download.enlightenment.org/releases
HOST_EINA_DIR=$HOST_BUILD_DIR/eina-${HOST_EINA_VERSION}
HOST_EINA_ENV="PKG_CONFIG_PATH=${HOST_BIN_DIR}/lib/pkgconfig"

build_host_eina() {
    test -e "$STATE_DIR/host_eina.installed" && return
    banner "Build host-eina"
    download $HOST_EINA_MIRROR $HOST_EINA
    extract_host $HOST_EINA
    apply_patches $HOST_EINA_DIR $HOST_EINA
    pushd $TOP_DIR
    cd $HOST_EINA_DIR
    (
    eval $HOST_EINA_ENV \
	./configure --prefix=$HOST_BIN_DIR
    ) || error
    make $MAKEARGS || error
    make $MAKEARGS install || error
    popd
    touch "$STATE_DIR/host_eina.installed"
}

build_host_eina
