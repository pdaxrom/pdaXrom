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

build_tweak_ps3() {
    test -e "$STATE_DIR/tweak_ps3-1.0" && return
    banner "Tweaking PS3 rootfs"

    $INSTALL -D -m 644 $GENERICFS_DIR/asound.state.PS3 $ROOTFS_DIR/var/lib/alsa/asound.state || error
    $INSTALL -D -m 644 $GENERICFS_DIR/etc/X11/xorg.conf $ROOTFS_DIR/etc/X11/xorg.conf || error
    ln -sf ../../../usr/bin/openbox-session $ROOTFS_DIR/etc/X11/xinit/xinitrc || error

    touch "$STATE_DIR/tweak_ps3-1.0"
}

build_tweak_ps3
