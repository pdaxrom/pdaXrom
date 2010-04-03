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

IPW2200_FW_VERSION=3.0
IPW2200_FW=ipw2200-fw-${IPW2200_FW_VERSION}.tgz
IPW2200_FW_MIRROR=http://bughost.org/firmware
IPW2200_FW_DIR=$BUILD_DIR/ipw2200-fw-${IPW2200_FW_VERSION}
IPW2200_FW_ENV="$CROSS_ENV_AC"

build_ipw2200_fw() {
    test -e "$STATE_DIR/ipw2200_fw.installed" && return
    banner "Build ipw2200-fw"
    download $IPW2200_FW_MIRROR $IPW2200_FW
    extract $IPW2200_FW
    apply_patches $IPW2200_FW_DIR $IPW2200_FW
    pushd $TOP_DIR
    cd $IPW2200_FW_DIR

    $INSTALL -D -m 644 ipw2200-bss.fw $ROOTFS_DIR/lib/firmware/ipw2200-bss.fw || error
    $INSTALL -D -m 644 ipw2200-ibss.fw $ROOTFS_DIR/lib/firmware/ipw2200-ibss.fw || error
    $INSTALL -D -m 644 ipw2200-sniffer.fw $ROOTFS_DIR/lib/firmware/ipw2200-sniffer.fw || error

    popd
    touch "$STATE_DIR/ipw2200_fw.installed"
}

build_ipw2200_fw
