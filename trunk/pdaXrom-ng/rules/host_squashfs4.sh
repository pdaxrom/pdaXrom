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

HOST_SQUASHFS4_VERSION=4.1
HOST_SQUASHFS4=squashfs${HOST_SQUASHFS4_VERSION}.tar.gz
HOST_SQUASHFS4_MIRROR=http://downloads.sourceforge.net/project/squashfs/squashfs/squashfs4.1
HOST_SQUASHFS4_DIR=$HOST_BUILD_DIR/squashfs${HOST_SQUASHFS4_VERSION}
HOST_SQUASHFS4_ENV=

build_host_squashfs4() {
    test -e "$STATE_DIR/host_squashfs4.installed" && return
    banner "Build host-squashfs4"
    download $HOST_SQUASHFS4_MIRROR $HOST_SQUASHFS4
    extract_host $HOST_SQUASHFS4
    apply_patches $HOST_SQUASHFS4_DIR $HOST_SQUASHFS4
    pushd $TOP_DIR
    cd $HOST_SQUASHFS4_DIR/squashfs-tools
    sed -i -e 's|XATTR_SUPPORT = 1|# XATTR_SUPPORT = 1|' Makefile
    make $MAKEARGS XZ_SUPPORT=1 INCLUDEDIR=-I${HOST_BIN_DIR}/include LIBS="-Wl,-rpath,${HOST_BIN_DIR}/lib -L${HOST_BIN_DIR}/lib -llzma -lz" || error
    make $MAKEARGS install INSTALL_DIR=${HOST_BIN_DIR}/bin || error

    popd
    touch "$STATE_DIR/host_squashfs4.installed"
}

build_host_squashfs4
