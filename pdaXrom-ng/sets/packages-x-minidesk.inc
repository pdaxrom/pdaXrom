. $RULES_DIR/tint2.sh

#. $RULES_DIR/bmpanel.sh

#. $RULES_DIR/gamin.sh
. $RULES_DIR/host_expat.sh
. $RULES_DIR/host_dbus.sh
. $RULES_DIR/host_dbus-glib.sh
. $RULES_DIR/dbus.sh
. $RULES_DIR/dbus-glib.sh
. $RULES_DIR/lxde-menu-cache.sh
. $RULES_DIR/libfm.sh
. $RULES_DIR/pcmanfm.sh

. $RULES_DIR/sn-monitor.sh
. $RULES_DIR/pekwm.sh
. $RULES_DIR/pekwm-themes.sh

. $RULES_DIR/xtrlock.sh

. $RULES_DIR/mrxvt05utf8.sh

#. $RULES_DIR/libvte.sh
#. $RULES_DIR/lxde-lxterminal.sh

. $RULES_DIR/htop.sh
. $RULES_DIR/ht.sh

. $RULES_DIR/minidesk-utils.sh

. $RULES_DIR/xdotool.sh

. $RULES_DIR/lxde-tweaks.sh


$INSTALL -D -m 755 ${GENERICFS_DIR}/minidesk/minidesk-session ${ROOTFS_DIR}/usr/bin/minidesk-session
echo "exec /usr/bin/minidesk-session" > ${ROOTFS_DIR}/etc/X11/Xsession.d/90_minidesk
