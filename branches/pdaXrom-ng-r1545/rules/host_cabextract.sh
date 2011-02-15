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

HOST_CABEXTRACT_VERSION=1.2
HOST_CABEXTRACT=cabextract-${HOST_CABEXTRACT_VERSION}.tar.gz
HOST_CABEXTRACT_MIRROR=http://www.cabextract.org.uk
HOST_CABEXTRACT_DIR=$HOST_BUILD_DIR/cabextract-${HOST_CABEXTRACT_VERSION}
HOST_CABEXTRACT_ENV=

build_host_cabextract() {
    test -e "$STATE_DIR/host_cabextract.installed" && return
    banner "Build host-cabextract"
    download $HOST_CABEXTRACT_MIRROR $HOST_CABEXTRACT
    extract_host $HOST_CABEXTRACT
    apply_patches $HOST_CABEXTRACT_DIR $HOST_CABEXTRACT
    pushd $TOP_DIR
    cd $HOST_CABEXTRACT_DIR
    (
    eval $HOST_CABEXTRACT_ENV \
	./configure --prefix=$HOST_BIN_DIR
    ) || error
    make $MAKEARGS || error
    make $MAKEARGS install || error
    popd
    touch "$STATE_DIR/host_cabextract.installed"
}

build_host_cabextract
