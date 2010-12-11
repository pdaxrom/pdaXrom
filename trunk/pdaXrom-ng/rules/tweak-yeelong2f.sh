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

build_tweak_yeelong2f() {
    test -e "$STATE_DIR/tweak_yeelong2f-1.0" && return
    banner "Tweaking yeelong2f rootfs"

    $INSTALL -D -m 644 $GENERICFS_DIR/yeelong2f/yeelong-xorg.conf $ROOTFS_DIR/etc/X11/xorg.conf || error

    if [ "$USE_LOGINMANAGER" = "" ]; then
	$INSTALL -D -m 755 $GENERICFS_DIR/etc/init.d/xstart $ROOTFS_DIR/etc/init.d/xstart || error
	if [ "$USE_FASTBOOT" = "yes" ]; then
	    install_rc_start xstart 03
	else
	    install_rc_start xstart 99
	fi
	install_rc_stop  xstart 01
    fi

    if [ -e $ROOTFS_DIR/usr/bin/matchbox-keyboard ]; then
	$INSTALL -D -m 755 $GENERICFS_DIR/mb-keyboard/mb-keyboard-switcher $ROOTFS_DIR/usr/bin/mb-keyboard-switcher || error
	$INSTALL -D -m 644 $GENERICFS_DIR/mb-keyboard/mb-keyboard-switcher.desktop $ROOTFS_DIR/usr/share/applications/mb-keyboard-switcher.desktop || error

	#$INSTALL -D -m 644 $GENERICFS_DIR/mb-keyboard/openbox-rc.xml $ROOTFS_DIR/etc/xdg/openbox/rc.xml || error
	if [ -d $ROOTFS_DIR/usr/share/lxpanel/profile/default/panels ]; then
	    $INSTALL -D -m 644 $GENERICFS_DIR/mb-keyboard/lxde-panel $ROOTFS_DIR/usr/share/lxpanel/profile/default/panels/panel || error
	fi
    fi

    touch "$STATE_DIR/tweak_yeelong2f-1.0"
}

build_tweak_yeelong2f
