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

P915RESOLUTION_VERSION=0.5.3
P915RESOLUTION=915resolution-${P915RESOLUTION_VERSION}.tar.gz
P915RESOLUTION_MIRROR=http://915resolution.mango-lang.org
P915RESOLUTION_DIR=$BUILD_DIR/915resolution-${P915RESOLUTION_VERSION}
P915RESOLUTION_ENV="$CROSS_ENV_AC"

build_915resolution() {
    test -e "$STATE_DIR/915resolution.installed" && return
    banner "Build 915resolution"
    download $P915RESOLUTION_MIRROR $P915RESOLUTION
    extract $P915RESOLUTION
    apply_patches $P915RESOLUTION_DIR $P915RESOLUTION
    pushd $TOP_DIR
    cd $P915RESOLUTION_DIR

    make clean

    make $MAKEARGS CC=${CROSS}gcc || error

    install_rootfs_usr_sbin ./915resolution
    $INSTALL -D -m 755 ${GENERICFS_DIR}/etc/init.d/uvesafb ${ROOTFS_DIR}/etc/init.d/uvesafb || error "install init.d script"
    install_rc_start uvesafb 00

    popd
    touch "$STATE_DIR/915resolution.installed"
}

build_915resolution
