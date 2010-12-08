. $RULES_DIR/lxde-lxmenu-data.sh
. $RULES_DIR/lxde-menu-cache.sh
. $RULES_DIR/lxde-lxpanel.sh
. $RULES_DIR/gamin.sh
. $RULES_DIR/libfm.sh
. $RULES_DIR/pcmanfm.sh
. $RULES_DIR/lxde-lxnm.sh
. $RULES_DIR/lxde-lxrandr.sh
. $RULES_DIR/lxde-lxsession.sh
. $RULES_DIR/lxsession-edit.sh
. $RULES_DIR/libvte.sh
. $RULES_DIR/lxde-lxterminal.sh

. $RULES_DIR/lxinput.sh
. $RULES_DIR/lxappearance.sh
. $RULES_DIR/lxshortcut.sh
. $RULES_DIR/lxtask.sh
. $RULES_DIR/lxde-common.sh
. $RULES_DIR/lxde-icon-theme.sh

if [ "$USE_LOGINMANAGER" = "lxdm" ]; then
    . $RULES_DIR/lxdm.sh
fi

. $RULES_DIR/minidesk-utils.sh
. $SETS_DIR/packages-net-addons.inc

. $RULES_DIR/htop.sh
#. $RULES_DIR/ht.sh

#. $RULES_DIR/lxde-lxmusic.sh
#. $RULES_DIR/lxde-lxlauncher.sh

#. $SETS_DIR/packages-gtkdialog.inc

. $RULES_DIR/dancesplash.sh

#. $RULES_DIR/lxde-tweaks.sh

