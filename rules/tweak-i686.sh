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
    test -e $ROOTFS_DIR/usr/bin/startlxde && ln -sf ../../../usr/bin/startlxde $ROOTFS_DIR/etc/X11/xinit/xinitrc

    $INSTALL -D -m 755 $GENERICFS_DIR/etc/init.d/xstart $ROOTFS_DIR/etc/init.d/xstart || error
    install_rc_start xstart 99
    install_rc_stop  xstart 01

    if [ -e $ROOTFS_DIR/usr/bin/matchbox-keyboard ]; then
	$INSTALL -D -m 755 $GENERICFS_DIR/mb-keyboard/mb-keyboard-switcher $ROOTFS_DIR/usr/bin/mb-keyboard-switcher || error
	$INSTALL -D -m 644 $GENERICFS_DIR/mb-keyboard/mb-keyboard-switcher.desktop $ROOTFS_DIR/usr/share/applications/mb-keyboard-switcher.desktop || error

	#$INSTALL -D -m 644 $GENERICFS_DIR/mb-keyboard/openbox-rc.xml $ROOTFS_DIR/etc/xdg/openbox/rc.xml || error
	if [ -d $ROOTFS_DIR/usr/share/lxpanel/profile/default/panels ]; then
	    $INSTALL -D -m 644 $GENERICFS_DIR/mb-keyboard/lxde-panel $ROOTFS_DIR/usr/share/lxpanel/profile/default/panels/panel || error
	fi
    fi

    touch "$STATE_DIR/tweak_i686cd-1.0"
}

build_tweak_i686cd
