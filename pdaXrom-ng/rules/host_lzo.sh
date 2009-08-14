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

HOST_LZO_VERSION=2.03
HOST_LZO=lzo-${HOST_LZO_VERSION}.tar.gz
HOST_LZO_MIRROR=http://www.oberhumer.com/opensource/lzo/download
HOST_LZO_DIR=$HOST_BUILD_DIR/lzo-${HOST_LZO_VERSION}
HOST_LZO_ENV=

build_host_lzo() {
    test -e "$STATE_DIR/host_lzo.installed" && return
    banner "Build host-lzo"
    download $HOST_LZO_MIRROR $HOST_LZO
    extract_host $HOST_LZO
    apply_patches $HOST_LZO_DIR $HOST_LZO
    pushd $TOP_DIR
    cd $HOST_LZO_DIR
    (
    eval $HOST_LZO_ENV \
	./configure --prefix=$HOST_BIN_DIR \
	    --disable-shared
    ) || error
    make $MAKEARGS || error
    make $MAKEARGS install || error
    popd
    touch "$STATE_DIR/host_lzo.installed"
}

build_host_lzo
