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

HOST_DISKDEV_CMDS_VERSION=332.14
HOST_DISKDEV_CMDS=diskdev_cmds-${HOST_DISKDEV_CMDS_VERSION}.tar.gz
HOST_DISKDEV_CMDS_MIRROR=http://gentoo.osuosl.org/distfiles
HOST_DISKDEV_CMDS_DIR=$HOST_BUILD_DIR/diskdev_cmds-${HOST_DISKDEV_CMDS_VERSION}
HOST_DISKDEV_CMDS_ENV=

build_host_diskdev_cmds() {
    test -e "$STATE_DIR/host_diskdev_cmds.installed" && return
    banner "Build host-diskdev_cmds"
    download $HOST_DISKDEV_CMDS_MIRROR $HOST_DISKDEV_CMDS
    extract_host $HOST_DISKDEV_CMDS
    apply_patches $HOST_DISKDEV_CMDS_DIR $HOST_DISKDEV_CMDS
    pushd $TOP_DIR
    cd $HOST_DISKDEV_CMDS_DIR

    make $MAKEARGS -f Makefile.lnx || error

    cp newfs_hfs.tproj/newfs_hfs ${HOST_BIN_DIR}/sbin/mkfs.hfsplus
    cp fsck_hfs.tproj/fsck_hfs   ${HOST_BIN_DIR}/sbin/fsck.hfsplus
    ln -sf mkfs.hfsplus ${HOST_BIN_DIR}/sbin/mkfs.hfs
    ln -sf fsck.hfsplus ${HOST_BIN_DIR}/sbin/fsck.hfs

    popd
    touch "$STATE_DIR/host_diskdev_cmds.installed"
}

build_host_diskdev_cmds
