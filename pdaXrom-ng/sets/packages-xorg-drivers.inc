#
# Input drivers
#
. $RULES_DIR/xf86-input-evdev.sh
. $RULES_DIR/xf86-input-joystick.sh
. $RULES_DIR/xf86-input-keyboard.sh
. $RULES_DIR/xf86-input-mouse.sh
. $RULES_DIR/xf86-input-synaptics.sh
#. $RULES_DIR/xf86-input-void.sh
if [ "$ENABLE_TSLIB" =  "yes" ]; then
. $RULES_DIR/xf86-input-tslib.sh
fi

#
# Video drivers
#
. $RULES_DIR/xf86-video-fbdev.sh

#
# Only for x86 and powerpc
#
if [ "`get_kernel_subarch $TARGET_ARCH`" = "i386" -o \
     "`get_kernel_subarch $TARGET_ARCH`" = "powerpc" ]; then

# xorg has problem with this driver in qemu
#. $RULES_DIR/xf86-video-cirrus.sh

. $RULES_DIR/xf86-video-ati.sh

if [ "$NVIDIA_CLOSESOURSE_VIDEO" = "yes" ]; then
    case $TARGET_ARCH in
    i*86-*)
	. $RULES_DIR/NVIDIA-Linux-x86.sh
	;;
    x86_64-*|amd64-*)
	. $RULES_DIR/NVIDIA-Linux-x86-64.sh
	;;
    esac
else
    . $RULES_DIR/xf86-video-nv.sh
fi

fi

#
# x86 specific drivers
#

if [ "`get_kernel_subarch $TARGET_ARCH`" = "i386" -o \
     "`get_kernel_subarch $TARGET_ARCH`" = "x86_64" ]; then

. $RULES_DIR/xf86-video-intel.sh
. $RULES_DIR/xf86-video-vesa.sh

#
# VMWare drivers
#
. $RULES_DIR/xf86-input-vmmouse.sh
. $RULES_DIR/xf86-video-vmware.sh

fi
