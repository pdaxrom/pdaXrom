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

HOST_LIBTOOL_VERSION=2.2.6
HOST_LIBTOOL=libtool-${HOST_LIBTOOL_VERSION}a.tar.gz
HOST_LIBTOOL_MIRROR=http://ftp.gnu.org/gnu/libtool
HOST_LIBTOOL_DIR=$HOST_BUILD_DIR/libtool-${HOST_LIBTOOL_VERSION}
HOST_LIBTOOL_ENV=

build_host_libtool() {
    test -e "$STATE_DIR/host_libtool.installed" && return
    banner "Build host-libtool"
    download $HOST_LIBTOOL_MIRROR $HOST_LIBTOOL
    extract_host $HOST_LIBTOOL
    apply_patches $HOST_LIBTOOL_DIR $HOST_LIBTOOL
    pushd $TOP_DIR
    cd $HOST_LIBTOOL_DIR
    (
    eval $HOST_LIBTOOL_ENV \
	./configure --prefix=$HOST_BIN_DIR \
		     --target=$TARGET_ARCH \
		     --host=$TARGET_ARCH \
		     --disable-ltdl-install
    ) || error
    make $MAKEARGS || error
    make $MAKEARGS install || error
    popd
    touch "$STATE_DIR/host_libtool.installed"
}

build_host_libtool
