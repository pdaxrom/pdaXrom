#
# GLX
#
. $RULES_DIR/libdrm.sh
. $RULES_DIR/glproto.sh
. $RULES_DIR/MesaLib.sh

. $RULES_DIR/xf86driproto.sh

#
# XServer
#
. $RULES_DIR/libpciaccess.sh
. $RULES_DIR/xorg-server.sh

#
# Xorg autoconfiguring at startup
#
. $RULES_DIR/xorg-init.sh
