#
# packet template
#
# Copyright (C) 2008 by Alexander Chukov <sash@pdaXrom.org>
#          
# See CREDITS for details about who has contributed to this project.
#
# For further information about the pdaXrom project and license conditions
# see the README file.
#

XORG_INIT=xorg-init
XORG_INIT_ENV=

build_xorg_init() {
    test -e "$STATE_DIR/xorg_init-1.0.0" && return
    banner "Build $XORG_INIT"

    $INSTALL -D -m 755 $GENERICFS_DIR/etc/init.d/xorg $ROOTFS_DIR/etc/init.d/xorg || error
    install_rc_start xorg 99

    touch "$STATE_DIR/xorg_init-1.0.0"
}

build_xorg_init
