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

build_tweak_i686cd() {
    test -e "$STATE_DIR/tweak_i686cd-1.0" && return
    banner "Tweaking i686 rootfs"

    #ln -sf ../../../usr/bin/openbox-session $ROOTFS_DIR/etc/X11/xinit/xinitrc || error

    touch "$STATE_DIR/tweak_i686cd-1.0"
}

build_tweak_i686cd
