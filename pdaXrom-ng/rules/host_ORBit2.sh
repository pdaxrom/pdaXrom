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

HOST_ORBIT2_VERSION=2.14.17
HOST_ORBIT2=ORBit2-${HOST_ORBIT2_VERSION}.tar.bz2
HOST_ORBIT2_MIRROR=ftp://ftp.gnome.org/pub/GNOME/sources/ORBit2/2.14
HOST_ORBIT2_DIR=$HOST_BUILD_DIR/ORBit2-${HOST_ORBIT2_VERSION}
HOST_ORBIT2_ENV="PKG_CONFIG=\"$HOST_PKG_CONFIG\" PKG_CONFIG_PATH=\"$HOST_PKG_CONFIG_PATH\""

build_host_ORBit2() {
    test -e "$STATE_DIR/host_ORBit2.installed" && return
    banner "Build host-ORBit2"
    download $HOST_ORBIT2_MIRROR $HOST_ORBIT2
    extract_host $HOST_ORBIT2
    apply_patches $HOST_ORBIT2_DIR $HOST_ORBIT2
    pushd $TOP_DIR
    cd $HOST_ORBIT2_DIR
    (
    unset PKG_CONFIG_PATH
    eval $HOST_ORBIT2_ENV \
	./configure --prefix=$HOST_BIN_DIR
    ) || error
    make $MAKEARGS || error "build"
    make $MAKEARGS install || error "install"
    popd
    touch "$STATE_DIR/host_ORBit2.installed"
}

build_host_ORBit2
