#
# packet template
#
# Copyright (C) 2009 by Alexander Chukov <sash@pdaXrom.org>
#
# See CREDITS for details about who has contributed to this project.
#
# For further information about the pdaXrom project and license conditions
# see the README file.
#

GDISK_VERSION=0.5.1
GDISK=gdisk-${GDISK_VERSION}.tgz
GDISK_MIRROR=http://downloads.sourceforge.net/project/gptfdisk/gptfdisk/0.5.1
GDISK_DIR=$BUILD_DIR/gdisk-${GDISK_VERSION}
GDISK_ENV="$CROSS_ENV_AC"

build_gdisk() {
    test -e "$STATE_DIR/gdisk.installed" && return
    banner "Build gdisk"
    download $GDISK_MIRROR $GDISK
    extract $GDISK
    apply_patches $GDISK_DIR $GDISK
    pushd $TOP_DIR
    cd $GDISK_DIR

    make $MAKEARGS CC=${CROSS}gcc CXX=${CROSS}g++ || error

    $INSTALL -D -m 755 gdisk ${ROOTFS_DIR}/sbin/gdisk || error "install to /sbin"
    $STRIP ${ROOTFS_DIR}/sbin/gdisk

    popd
    touch "$STATE_DIR/gdisk.installed"
}

build_gdisk
