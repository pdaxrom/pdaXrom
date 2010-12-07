#
# GLX
#
. $RULES_DIR/libdrm.sh
. $RULES_DIR/glproto.sh
. $RULES_DIR/dri2proto.sh
. $RULES_DIR/dmxproto.sh
. $RULES_DIR/libdmx.sh
. $RULES_DIR/talloc.sh
. $RULES_DIR/MesaLib.sh
. $RULES_DIR/xf86driproto.sh

#
# XServer
#
. $RULES_DIR/libpciaccess.sh
. $RULES_DIR/xorg-server.sh

. $RULES_DIR/xkeyboard-config.sh

#
# Xorg autoconfiguring at startup
#
. $RULES_DIR/xorg-init.sh
