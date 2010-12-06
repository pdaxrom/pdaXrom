#
# DirectFB
#
. $RULES_DIR/atk.sh
. $RULES_DIR/DirectFB.sh

#
# Gtk2
#
. $RULES_DIR/pixman.sh
. $RULES_DIR/cairo-directfb.sh
. $RULES_DIR/pango-directfb.sh
. $RULES_DIR/gtk2-directfb.sh

#
# icons set
#
. $RULES_DIR/host_intltool.sh
. $RULES_DIR/host_icon-naming-utils.sh
. $RULES_DIR/gnome-icon-theme.sh
. $RULES_DIR/host_shared-mime-info.sh
. $RULES_DIR/shared-mime-info.sh
