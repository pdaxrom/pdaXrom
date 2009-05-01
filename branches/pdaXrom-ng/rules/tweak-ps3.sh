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

    $INSTALL -D -m 755 $GENERICFS_DIR/etc/init.d/ps3vswap $ROOTFS_DIR/etc/init.d/ps3vswap || error
    install_rc_start ps3vswap 50
    install_rc_stop  ps3vswap 70

    $INSTALL -D -m 644 $GENERICFS_DIR/asound.state.PS3 $ROOTFS_DIR/var/lib/alsa/asound.state || error
    $INSTALL -D -m 644 $GENERICFS_DIR/etc/X11/xorg.conf $ROOTFS_DIR/etc/X11/xorg.conf || error

    #ln -sf ../../../usr/bin/openbox-session $ROOTFS_DIR/etc/X11/xinit/xinitrc || error
    test -e $ROOTFS_DIR/usr/bin/startlxde && ln -sf ../../../usr/bin/startlxde $ROOTFS_DIR/etc/X11/xinit/xinitrc

    for f in mach64_dri.so r128_dri.so r200_dri.so r300_dri.so radeon_dri.so tdfx_dri.so; do
	rm -f $ROOTFS_DIR/usr/lib/dri/$f
    done

    if [ -d $ROOTFS_DIR/etc/mplayer ]; then
	echo "vo=x11" > $ROOTFS_DIR/etc/mplayer/mplayer.conf
    fi

    if [ -e $ROOTFS_DIR/usr/bin/matchbox-keyboard ]; then
	$INSTALL -D -m 755 $GENERICFS_DIR/mb-keyboard/mb-keyboard-switcher $ROOTFS_DIR/usr/bin/mb-keyboard-switcher || error
	$INSTALL -D -m 644 $GENERICFS_DIR/mb-keyboard/mb-keyboard-switcher.desktop $ROOTFS_DIR/usr/share/applications/mb-keyboard-switcher.desktop || error

	$INSTALL -D -m 644 $GENERICFS_DIR/mb-keyboard/openbox-rc.xml $ROOTFS_DIR/etc/xdg/openbox/rc.xml || error
	if [ -d $ROOTFS_DIR/usr/share/lxpanel/profile/default/panels ]; then
	    $INSTALL -D -m 644 $GENERICFS_DIR/mb-keyboard/lxde-panel $ROOTFS_DIR/usr/share/lxpanel/profile/default/panels/panel || error
	fi
    fi
    
    $INSTALL -D -m 755 $GENERICFS_DIR/etc/init.d/xstart $ROOTFS_DIR/etc/init.d/xstart || error
    if [ "$USE_FASTBOOT" = "yes" ]; then
	install_rc_start xstart 03
    else
	install_rc_start xstart 99
    fi
    install_rc_stop  xstart 01

    touch "$STATE_DIR/tweak_ps3-1.0"
}

build_tweak_ps3
