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
. $RULES_DIR/xf86-video-amd.sh
. $RULES_DIR/xf86-video-apm.sh
. $RULES_DIR/xf86-video-ark.sh
. $RULES_DIR/xf86-video-ast.sh
. $RULES_DIR/xf86-video-ati.sh
. $RULES_DIR/xf86-video-chips.sh
. $RULES_DIR/xf86-video-cirrus.sh
#. $RULES_DIR/xf86-video-cyrix.sh
. $RULES_DIR/xf86-video-dummy.sh
. $RULES_DIR/xf86-video-fbdev.sh
. $RULES_DIR/xf86-video-geode.sh
. $RULES_DIR/xf86-video-glint.sh
. $RULES_DIR/xf86-video-i128.sh
. $RULES_DIR/xf86-video-i740.sh
#. $RULES_DIR/xf86-video-i810.sh
. $RULES_DIR/xf86-video-intel.sh
. $RULES_DIR/xf86-video-mach64.sh
. $RULES_DIR/xf86-video-mga.sh
. $RULES_DIR/xf86-video-neomagic.sh
. $RULES_DIR/xf86-video-newport.sh
. $RULES_DIR/xf86-video-nsc.sh
. $RULES_DIR/xf86-video-nv.sh
. $RULES_DIR/xf86-video-openchrome.sh
. $RULES_DIR/xf86-video-r128.sh
. $RULES_DIR/xf86-video-radeonhd.sh
. $RULES_DIR/xf86-video-rendition.sh
. $RULES_DIR/xf86-video-s3.sh
. $RULES_DIR/xf86-video-s3virge.sh
. $RULES_DIR/xf86-video-savage.sh
. $RULES_DIR/xf86-video-siliconmotion.sh
. $RULES_DIR/xf86-video-sis.sh
. $RULES_DIR/xf86-video-sisusb.sh
. $RULES_DIR/xf86-video-tdfx.sh
. $RULES_DIR/xf86-video-tga.sh
. $RULES_DIR/xf86-video-trident.sh
. $RULES_DIR/xf86-video-tseng.sh
. $RULES_DIR/xf86-video-v4l.sh
#. $RULES_DIR/xf86-video-vermilion.sh
#. $RULES_DIR/xf86-video-via.sh
. $RULES_DIR/xf86-video-voodoo.sh
. $RULES_DIR/xf86-video-xgi.sh
#. $RULES_DIR/xf86-video-xgixp.sh

#
# x86 specific drivers
#

if [ "`get_kernel_subarch $TARGET_ARCH`" = "i386" ]; then

#
# VESA driver
#
. $RULES_DIR/xf86-video-vesa.sh

#
# VMWare drivers
#
. $RULES_DIR/xf86-input-vmmouse.sh
. $RULES_DIR/xf86-video-vmware.sh

fi
