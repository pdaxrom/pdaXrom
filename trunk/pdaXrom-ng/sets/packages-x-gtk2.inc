#
# Gtk2
#
. $RULES_DIR/xorg-startup-notification.sh
. $RULES_DIR/cairo.sh
. $RULES_DIR/pango.sh
. $RULES_DIR/tiff.sh
. $RULES_DIR/imlib2.sh
. $RULES_DIR/atk.sh
. $RULES_DIR/gdk-pixbuf.sh
. $RULES_DIR/gtk2.sh

#
#
#
. $RULES_DIR/clearlooks.sh

# SVG support
. $RULES_DIR/libgsf.sh
. $RULES_DIR/libcroco.sh
. $RULES_DIR/librsvg.sh

#
# icons set
#
. $RULES_DIR/host_intltool.sh
. $RULES_DIR/host_icon-naming-utils.sh
. $RULES_DIR/gnome-icon-theme.sh
. $RULES_DIR/host_shared-mime-info.sh
. $RULES_DIR/shared-mime-info.sh
