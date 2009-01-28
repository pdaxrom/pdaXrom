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

HOST_MTD_UTILS_VERSION=current
HOST_MTD_UTILS=mtd-utils-${HOST_MTD_UTILS_VERSION}
HOST_MTD_UTILS_MIRROR=git://git.infradead.org/mtd-utils.git
HOST_MTD_UTILS_DIR=$HOST_BUILD_DIR/mtd-utils-${HOST_MTD_UTILS_VERSION}
HOST_MTD_UTILS_ENV=

build_host_mtd_utils() {
    test -e "$STATE_DIR/host_mtd_utils.installed" && return
    banner "Build host-mtd-utils"
    download_git $HOST_MTD_UTILS_MIRROR $HOST_MTD_UTILS
    extract_host $HOST_MTD_UTILS
    apply_patches $HOST_MTD_UTILS_DIR $HOST_MTD_UTILS
    pushd $TOP_DIR
    cd $HOST_MTD_UTILS_DIR
    make $MAKEARGS  \
	WITHOUT_XATTR=1 \
	CFLAGS="-O2 -g -I$HOST_BIN_DIR/include -I$HOST_BIN_DIR/include" \
	LDFLAGS="-L$HOST_BIN_DIR/lib -L$HOST_BIN_DIR/lib" \
	|| error

    make $MAKEARGS  \
	WITHOUT_XATTR=1 \
	CFLAGS="-O2 -g -I$HOST_BIN_DIR/include -I$HOST_BIN_DIR/include" \
	LDFLAGS="-L$HOST_BIN_DIR/lib -L$HOST_BIN_DIR/lib" \
	DESTDIR=$HOST_BIN_DIR \
	PREFIX=/ \
	SBINDIR=/bin \
	install \
	|| error

#	ZLIBCPPFLAGS=-I$HOST_BIN_DIR/include \
#	LZOCPPFLAGS=-I$HOST_BIN_DIR/include \
#	ZLIBLDFLAGS=-L$HOST_BIN_DIR/lib \
#	LZOLDFLAGS=-L$HOST_BIN_DIR/lib \

    popd
    touch "$STATE_DIR/host_mtd_utils.installed"
}

build_host_mtd_utils
