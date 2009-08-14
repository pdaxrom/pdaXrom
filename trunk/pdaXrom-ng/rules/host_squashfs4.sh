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

HOST_SQUASHFS4_VERSION=20090125
HOST_SQUASHFS4=squashfs-${HOST_SQUASHFS4_VERSION}.tar.bz2
HOST_SQUASHFS4_MIRROR=http://wiki.pdaXrom.org/downloads/src
HOST_SQUASHFS4_DIR=$HOST_BUILD_DIR/squashfs-${HOST_SQUASHFS4_VERSION}
HOST_SQUASHFS4_ENV=

build_host_squashfs4() {
    test -e "$STATE_DIR/host_squashfs4.installed" && return
    banner "Build host-squashfs4"
    download $HOST_SQUASHFS4_MIRROR $HOST_SQUASHFS4
    extract_host $HOST_SQUASHFS4
    apply_patches $HOST_SQUASHFS4_DIR $HOST_SQUASHFS4
    pushd $TOP_DIR
    cd $HOST_SQUASHFS4_DIR

    make $MAKEARGS -C squashfs-tools || error

    $INSTALL -D -m 755 squashfs-tools/mksquashfs $HOST_BIN_DIR/bin/mksquashfs || error

    popd
    touch "$STATE_DIR/host_squashfs4.installed"
}

build_host_squashfs4
