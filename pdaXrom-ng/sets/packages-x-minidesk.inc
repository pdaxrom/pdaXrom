. $RULES_DIR/tint2.sh
#. $RULES_DIR/bmpanel.sh

. $RULES_DIR/gamin.sh
. $RULES_DIR/pcmanfm.sh

. $RULES_DIR/mrxvt05utf8.sh

#. $RULES_DIR/libvte.sh
#. $RULES_DIR/lxde-lxterminal.sh

. $RULES_DIR/htop.sh
. $RULES_DIR/ht.sh

. $RULES_DIR/minidesk-utils.sh

. $RULES_DIR/lxde-tweaks.sh


$INSTALL -D -m 755 ${GENERICFS_DIR}/minidesk/minidesk-session ${ROOTFS_DIR}/usr/bin/minidesk-session
echo "exec /usr/bin/minidesk-session" > ${ROOTFS_DIR}/etc/X11/Xsession.d/90_minidesk
