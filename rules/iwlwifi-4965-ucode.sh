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

IWLWIFI_4965_UCODE=iwlwifi-4965-ucode-228.57.2.23.tgz
IWLWIFI_4965_UCODE_MIRROR=http://intellinuxwireless.org/iwlwifi/downloads
IWLWIFI_4965_UCODE_DIR=$BUILD_DIR/iwlwifi-4965-ucode-228.57.2.23
IWLWIFI_4965_UCODE_ENV="$CROSS_ENV_AC"

build_iwlwifi_4965_ucode() {
    test -e "$STATE_DIR/iwlwifi_4965_ucode.installed" && return
    banner "Build iwlwifi-4965-ucode"
    download $IWLWIFI_4965_UCODE_MIRROR $IWLWIFI_4965_UCODE
    extract $IWLWIFI_4965_UCODE
    apply_patches $IWLWIFI_4965_UCODE_DIR $IWLWIFI_4965_UCODE
    pushd $TOP_DIR
    cd $IWLWIFI_4965_UCODE_DIR

    $INSTALL -D -m 644 iwlwifi-4965-2.ucode $ROOTFS_DIR/lib/firmware/iwlwifi-4965-2.ucode || error

    popd
    touch "$STATE_DIR/iwlwifi_4965_ucode.installed"
}

build_iwlwifi_4965_ucode
