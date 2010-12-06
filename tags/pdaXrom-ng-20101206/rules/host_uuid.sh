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

HOST_UUID_VERSION=1.6.2
HOST_UUID=uuid-${HOST_UUID_VERSION}.tar.gz
HOST_UUID_MIRROR=ftp://ftp.ossp.org/pkg/lib/uuid
HOST_UUID_DIR=$HOST_BUILD_DIR/uuid-${HOST_UUID_VERSION}
HOST_UUID_ENV=

build_host_uuid() {
    test -e "$STATE_DIR/host_uuid.installed" && return
    banner "Build host-uuid"
    download $HOST_UUID_MIRROR $HOST_UUID
    extract_host $HOST_UUID
    apply_patches $HOST_UUID_DIR $HOST_UUID
    pushd $TOP_DIR
    cd $HOST_UUID_DIR
    (
    eval $HOST_UUID_ENV \
	./configure --prefix=$HOST_BIN_DIR \
	    --disable-shared \
	    --without-perl \
	    --without-php \
	    --without-pgsql
    ) || error
    make $MAKEARGS || error
    make $MAKEARGS install || error
    mkdir -p $HOST_BIN_DIR/include/uuid || error
    ln -sf ../uuid.h $HOST_BIN_DIR/include/uuid/ || error
    popd
    touch "$STATE_DIR/host_uuid.installed"
}

build_host_uuid
