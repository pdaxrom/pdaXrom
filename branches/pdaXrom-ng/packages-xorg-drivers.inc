#
# Input drivers
#
. $RULES_DIR/xf86-input-evdev.sh
. $RULES_DIR/xf86-input-joystick.sh
. $RULES_DIR/xf86-input-keyboard.sh
. $RULES_DIR/xf86-input-mouse.sh
. $RULES_DIR/xf86-input-synaptics.sh
. $RULES_DIR/xf86-input-void.sh

#
# Video drivers
#
. $RULES_DIR/xf86-video-fbdev.sh
. $RULES_DIR/xf86-video-cirrus.sh
. $RULES_DIR/xf86-video-vesa.sh
