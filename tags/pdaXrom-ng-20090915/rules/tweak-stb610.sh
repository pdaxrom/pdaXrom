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

build_tweak_stb610() {
    test -e "$STATE_DIR/tweak_stb610-1.0" && return
    banner "Tweaking stb610 rootfs"

    grep -q 'ttyS0' $ROOTFS_DIR/etc/inittab || echo 'ttyS0::respawn:/sbin/getty -L 115200 /dev/ttyS0 linux' >> $ROOTFS_DIR/etc/inittab

    #ln -sf ../../../usr/bin/openbox-session $ROOTFS_DIR/etc/X11/xinit/xinitrc || error
    test -e $ROOTFS_DIR/usr/bin/startlxde && ln -sf ../../../usr/bin/startlxde $ROOTFS_DIR/etc/X11/xinit/xinitrc

    $INSTALL -D -m 755 $GENERICFS_DIR/etc/init.d/xstart $ROOTFS_DIR/etc/init.d/xstart || error
    if [ "$USE_FASTBOOT" = "yes" ]; then
	install_rc_start xstart 03
    else
	install_rc_start xstart 99
    fi
    install_rc_stop  xstart 01

    touch "$STATE_DIR/tweak_stb610-1.0"
}

build_tweak_stb610
