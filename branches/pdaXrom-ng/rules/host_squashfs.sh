#
# host packet template
#
# Copyright (C) 2008 by Alexander Chukov <sash@pdaXrom.org>
#          
# See CREDITS for details about who has contributed to this project.
#
# For further information about the pdaXrom project and license conditions
# see the README file.
#

HOST_SQUASHFS=squashfs3.4.tar.gz
HOST_SQUASHFS_MIRROR=http://downloads.sourceforge.net/squashfs
HOST_SQUASHFS_DIR=$HOST_BUILD_DIR/squashfs3.4
HOST_SQUASHFS_ENV=

build_host_squashfs() {
    test -e "$STATE_DIR/host_squashfs.installed" && return
    banner "Build host-squashfs"
    download $HOST_SQUASHFS_MIRROR $HOST_SQUASHFS
    extract_host $HOST_SQUASHFS
    apply_patches $HOST_SQUASHFS_DIR $HOST_SQUASHFS
    pushd $TOP_DIR
    cd $HOST_SQUASHFS_DIR
    make -C squashfs-tools || error

    $INSTALL -D -m 755 squashfs-tools/mksquashfs $HOST_BIN_DIR/bin/mksquashfs || error
    $INSTALL -D -m 755 squashfs-tools/unsquashfs $HOST_BIN_DIR/bin/unsquashfs || error
    
    popd
    touch "$STATE_DIR/host_squashfs.installed"
}

build_host_squashfs
