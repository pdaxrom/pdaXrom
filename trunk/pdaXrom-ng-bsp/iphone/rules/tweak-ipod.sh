#
# packet template
#
# Copyright (C) 2010 by Alexander Chukov <sash@pdaXrom.org>
#
# See CREDITS for details about who has contributed to this project.
#
# For further information about the pdaXrom project and license conditions
# see the README file.
#

build_tweak_ipod() {
    test -e "$STATE_DIR/tweak_ipod" && return
    banner "Tweaking rootfs"

    if [ "$USE_LOGINMANAGER" = "" ]; then
	$INSTALL -D -m 755 $GENERICFS_DIR/etc/init.d/xstart $ROOTFS_DIR/etc/init.d/xstart || error
	if [ "$USE_FASTBOOT" = "yes" ]; then
	    install_rc_start xstart 03
	else
	    install_rc_start xstart 99
	fi
	install_rc_stop  xstart 01
    fi

    touch "$STATE_DIR/tweak_ipod"
}

build_tweak_ipod
