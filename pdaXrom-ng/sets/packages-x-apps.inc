. $SETS_DIR/packages-gconf.inc

if [ "$USE_LOGINMANAGER" = "yes" ]; then
    . $RULES_DIR/slim.sh
fi

. $RULES_DIR/openbox.sh

#. $RULES_DIR/pekwm.sh

#. $RULES_DIR/libtool.sh
#. $RULES_DIR/libcanberra.sh
#. $RULES_DIR/metacity.sh

# Minimal X display lock program
. $RULES_DIR/xtrlock.sh

#. $RULES_DIR/Xdialog.sh

#. $RULES_DIR/idesk.sh

#
# grab X11 screen
#
. $RULES_DIR/imlib2.sh
. $RULES_DIR/giblib.sh
. $RULES_DIR/scrot.sh

#. $SETS_DIR/packages-firefox.inc

. $SETS_DIR/packages-midori.inc

#
# skipstone-gecko
#
#. $RULES_DIR/skipstone-gecko.sh

#
# skipstone
#
#. $RULES_DIR/skipstone.sh

. $SETS_DIR/packages-pidgin.inc

#
# xchat
#
. $RULES_DIR/libsexy.sh
. $RULES_DIR/xchat.sh

#
# transmission
#
. $RULES_DIR/curl.sh
. $RULES_DIR/transmission.sh

#
# mplayer
#
. $RULES_DIR/SDL.sh
. $RULES_DIR/libogg.sh
. $RULES_DIR/libvorbis.sh
. $RULES_DIR/speex.sh
. $RULES_DIR/libtheora.sh
. $RULES_DIR/libv4l.sh

. $RULES_DIR/mplayer.sh
. $RULES_DIR/clearplayer.sh
