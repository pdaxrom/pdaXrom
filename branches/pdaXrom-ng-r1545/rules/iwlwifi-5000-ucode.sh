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

IWLWIFI_5000_UCODE=iwlwifi-5000-ucode-5.4.A.11.tar.gz
IWLWIFI_5000_UCODE_MIRROR=http://intellinuxwireless.org/iwlwifi/downloads
IWLWIFI_5000_UCODE_DIR=$BUILD_DIR/iwlwifi-5000-ucode-5.4.A.11
IWLWIFI_5000_UCODE_ENV="$CROSS_ENV_AC"

build_iwlwifi_5000_ucode() {
    test -e "$STATE_DIR/iwlwifi_5000_ucode.installed" && return
    banner "Build iwlwifi-5000-ucode"
    download $IWLWIFI_5000_UCODE_MIRROR $IWLWIFI_5000_UCODE
    extract $IWLWIFI_5000_UCODE
    apply_patches $IWLWIFI_5000_UCODE_DIR $IWLWIFI_5000_UCODE
    pushd $TOP_DIR
    cd $IWLWIFI_5000_UCODE_DIR

    $INSTALL -D -m 644 iwlwifi-5000-1.ucode $ROOTFS_DIR/lib/firmware/iwlwifi-5000-1.ucode || error

    popd
    touch "$STATE_DIR/iwlwifi_5000_ucode.installed"
}

build_iwlwifi_5000_ucode
