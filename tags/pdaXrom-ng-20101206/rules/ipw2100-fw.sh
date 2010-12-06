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

IPW2100_FW_VERSION=1.3
IPW2100_FW=ipw2100-fw-${IPW2100_FW_VERSION}.tgz
IPW2100_FW_MIRROR=http://bughost.org/firmware
IPW2100_FW_DIR=$BUILD_DIR/ipw2100-fw-${IPW2100_FW_VERSION}
IPW2100_FW_ENV="$CROSS_ENV_AC"

build_ipw2100_fw() {
    test -e "$STATE_DIR/ipw2100_fw.installed" && return
    banner "Build ipw2100-fw"
    download $IPW2100_FW_MIRROR $IPW2100_FW
    mkdir -p $IPW2100_FW_DIR
    pushd $TOP_DIR
    cd $IPW2100_FW_DIR
    tar xfz $SRC_DIR/$IPW2100_FW

    for f in *.fw ; do
	$INSTALL -D -m 644 $f $ROOTFS_DIR/lib/firmware/$f || error
    done

    popd
    touch "$STATE_DIR/ipw2100_fw.installed"
}

build_ipw2100_fw
