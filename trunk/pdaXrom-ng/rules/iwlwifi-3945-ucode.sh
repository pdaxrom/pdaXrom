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

IWLWIFI_3945_UCODE=iwlwifi-3945-ucode-15.28.2.8.tgz
IWLWIFI_3945_UCODE_MIRROR=http://intellinuxwireless.org/iwlwifi/downloads
IWLWIFI_3945_UCODE_DIR=$BUILD_DIR/iwlwifi-3945-ucode-15.28.2.8
IWLWIFI_3945_UCODE_ENV="$CROSS_ENV_AC"

build_iwlwifi_3945_ucode() {
    test -e "$STATE_DIR/iwlwifi_3945_ucode.installed" && return
    banner "Build iwlwifi-3945-ucode"
    download $IWLWIFI_3945_UCODE_MIRROR $IWLWIFI_3945_UCODE
    extract $IWLWIFI_3945_UCODE
    apply_patches $IWLWIFI_3945_UCODE_DIR $IWLWIFI_3945_UCODE
    pushd $TOP_DIR
    cd $IWLWIFI_3945_UCODE_DIR
    
    $INSTALL -D -m 644 iwlwifi-3945-2.ucode $ROOTFS_DIR/lib/firmware/iwlwifi-3945-2.ucode || error

    popd
    touch "$STATE_DIR/iwlwifi_3945_ucode.installed"
}

build_iwlwifi_3945_ucode
