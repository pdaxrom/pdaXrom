. $RULES_DIR/libnotify.sh
. $RULES_DIR/iso-codes.sh
. $RULES_DIR/libxklavier.sh
. $RULES_DIR/libtool.sh
. $RULES_DIR/libogg.sh
. $RULES_DIR/libvorbis.sh
. $RULES_DIR/libcanberra.sh
. $RULES_DIR/xfce4-dev-tools.sh
. $RULES_DIR/libxfce4util.sh
. $RULES_DIR/xfconf.sh
. $RULES_DIR/libglade.sh
. $RULES_DIR/libxfcegui4.sh

. $RULES_DIR/exo.sh
. $RULES_DIR/libwnck.sh
. $RULES_DIR/garcon.sh
. $RULES_DIR/libxfce4ui.sh
. $RULES_DIR/xfce4-panel.sh

. $RULES_DIR/gamin.sh
. $RULES_DIR/Thunar.sh
. $RULES_DIR/xfce4-settings.sh

. $RULES_DIR/xfce4-session.sh

. $RULES_DIR/xfwm4.sh
. $RULES_DIR/xfdesktop.sh

. $RULES_DIR/thunar-vfs.sh
. $RULES_DIR/xfce4-appfinder.sh
# xfce4-mixer
. $RULES_DIR/xfce-utils.sh
# xfprint
. $RULES_DIR/gtk-xfce-engine.sh
. $RULES_DIR/mousepad.sh

#. $RULES_DIR/libvte.sh
#. $RULES_DIR/Terminal.sh

. $RULES_DIR/libvte.sh
. $RULES_DIR/lxde-lxterminal.sh

# xfcalendar
# xfmedia

if [ "$USE_LOGINMANAGER" = "lxdm" ]; then
    . $RULES_DIR/target-bash.sh
    . $RULES_DIR/lxdm.sh
fi
if [ "$USE_LOGINMANAGER" = "slim" ]; then
    . $RULES_DIR/target-bash.sh
    . $RULES_DIR/slim.sh
fi
