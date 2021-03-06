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

    install_rootfs_usr_lib ${TOOLCHAIN_SYSROOT}/usr/lib/libspe2.so.2.2.80

    if [ -e $ROOTFS_DIR/usr/bin/elfspe-register ]; then
	$INSTALL -D -m 755 $GENERICFS_DIR/etc/init.d/elfspe $ROOTFS_DIR/etc/init.d/elfspe || error
	install_rc_start elfspe 50
    fi

    $INSTALL -D -m 755 $GENERICFS_DIR/etc/init.d/ps3vswap $ROOTFS_DIR/etc/init.d/ps3vswap || error
    install_rc_start ps3vswap 50
    install_rc_stop  ps3vswap 70

    $INSTALL -D -m 644 $GENERICFS_DIR/asound.state.PS3 $ROOTFS_DIR/var/lib/alsa/asound.state || error
    touch $ROOTFS_DIR/etc/X11/xorg.conf

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

    if [ "$USE_LOGINMANAGER" = "" ]; then
	$INSTALL -D -m 755 $GENERICFS_DIR/etc/init.d/xstart $ROOTFS_DIR/etc/init.d/xstart || error
	if [ "$USE_FASTBOOT" = "yes" ]; then
	    install_rc_start xstart 03
	    $INSTALL -D -m 644 $GENERICFS_DIR/modules.PS3 $ROOTFS_DIR/etc/modules || error
	else
	    install_rc_start xstart 99
	fi
	install_rc_stop  xstart 01
    fi

    touch "$STATE_DIR/tweak_ps3-1.0"
}

build_tweak_ps3
