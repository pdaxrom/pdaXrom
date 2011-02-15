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

. $RULES_DIR/linux-firmware.sh

build_ralink_firmware() {
    test -e "$STATE_DIR/ralink_firmware.installed" && return
    banner "Build ralink-firmware"

    cp -f ${LINUX_FIRMWARE_DIR}/firmware/rt2x00/*.bin ${ROOTFS_DIR}/lib/firmware/

    touch "$STATE_DIR/ralink_firmware.installed"
}

build_ralink_firmware
