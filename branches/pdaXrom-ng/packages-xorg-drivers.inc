#
# Input drivers
#
. $RULES_DIR/xf86-input-evdev.sh
. $RULES_DIR/xf86-input-joystick.sh
. $RULES_DIR/xf86-input-keyboard.sh
. $RULES_DIR/xf86-input-mouse.sh
. $RULES_DIR/xf86-input-synaptics.sh
#. $RULES_DIR/xf86-input-void.sh

#
# Video drivers
#
. $RULES_DIR/xf86-video-fbdev.sh
. $RULES_DIR/xf86-video-cirrus.sh
. $RULES_DIR/xf86-video-ati.sh
. $RULES_DIR/xf86-video-nv.sh

#
# x86 specific drivers
#

if [ "`get_kernel_subarch $TARGET_ARCH`" = "i386" ]; then

. $RULES_DIR/xf86-video-intel.sh
. $RULES_DIR/xf86-video-vesa.sh

#
# VMWare drivers
#
. $RULES_DIR/xf86-input-vmmouse.sh
. $RULES_DIR/xf86-video-vmware.sh

fi
