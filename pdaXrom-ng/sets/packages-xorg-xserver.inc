#
# GLX
#
. $RULES_DIR/libdrm.sh
. $RULES_DIR/glproto.sh
. $RULES_DIR/dri2proto.sh
. $RULES_DIR/MesaLib.sh

case $TARGET_ARCH in
i*86-*)
    if [ "$NVIDIA_CLOSESOURSE_VIDEO" = "yes" ]; then
	. $RULES_DIR/NVIDIA-Linux-x86.sh
    fi
    ;;
x86_64-*|amd64-*)
    if [ "$NVIDIA_CLOSESOURSE_VIDEO" = "yes" ]; then
	. $RULES_DIR/NVIDIA-Linux-x86-64.sh
    fi
    ;;
esac

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
