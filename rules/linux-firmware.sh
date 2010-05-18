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

LINUX_FIRMWARE_VERSION=1.26
LINUX_FIRMWARE=linux-firmware_${LINUX_FIRMWARE_VERSION}.tar.gz
LINUX_FIRMWARE_MIRROR=http://archive.ubuntu.com/ubuntu/pool/main/l/linux-firmware
LINUX_FIRMWARE_DIR=$BUILD_DIR/linux-firmware-karmic
LINUX_FIRMWARE_ENV="$CROSS_ENV_AC"

build_linux_firmware() {
    test -e "$STATE_DIR/linux_firmware.installed" && return
    banner "Build linux-firmware"
    download $LINUX_FIRMWARE_MIRROR $LINUX_FIRMWARE
    extract $LINUX_FIRMWARE
    apply_patches $LINUX_FIRMWARE_DIR $LINUX_FIRMWARE
    pushd $TOP_DIR
    cd $LINUX_FIRMWARE_DIR

    popd
    touch "$STATE_DIR/linux_firmware.installed"
}

build_linux_firmware
