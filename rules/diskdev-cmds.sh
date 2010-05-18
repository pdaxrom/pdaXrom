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

DISKDEV_CMDS_VERSION=332.14
DISKDEV_CMDS=diskdev_cmds-${DISKDEV_CMDS_VERSION}.tar.gz
DISKDEV_CMDS_MIRROR=http://gentoo.osuosl.org/distfiles
DISKDEV_CMDS_DIR=$BUILD_DIR/diskdev_cmds-${DISKDEV_CMDS_VERSION}
DISKDEV_CMDS_ENV=

build_diskdev_cmds() {
    test -e "$STATE_DIR/diskdev_cmds.installed" && return
    banner "Build host-diskdev_cmds"
    download $DISKDEV_CMDS_MIRROR $DISKDEV_CMDS
    extract $DISKDEV_CMDS
    apply_patches $DISKDEV_CMDS_DIR $DISKDEV_CMDS
    pushd $TOP_DIR
    cd $DISKDEV_CMDS_DIR

    make $MAKEARGS -f Makefile.lnx CC=${CROSS}gcc CXX=${CROSS}g++ AR=${CROSS}ar OPT_LDFLAGS="-Wl,-rpath,${TARGET_LIB} -L${TARGET_LIB}" || error

    cp newfs_hfs.tproj/newfs_hfs ${ROOTFS_DIR}/sbin/mkfs.hfsplus
    cp fsck_hfs.tproj/fsck_hfs   ${ROOTFS_DIR}/sbin/fsck.hfsplus
    ln -sf mkfs.hfsplus ${ROOTFS_DIR}/sbin/mkfs.hfs
    ln -sf fsck.hfsplus ${ROOTFS_DIR}/sbin/fsck.hfs

    ${STRIP} ${ROOTFS_DIR}/sbin/mkfs.hfsplus
    ${STRIP} ${ROOTFS_DIR}/sbin/fsck.hfsplus

    popd
    touch "$STATE_DIR/diskdev_cmds.installed"
}

build_diskdev_cmds
