#!/bin/sh

. $RULES_DIR/libogg.sh
. $RULES_DIR/libvorbis.sh
. $RULES_DIR/host_findutils.sh
. $RULES_DIR/host_libIDL.sh
. $RULES_DIR/libIDL.sh
#. $RULES_DIR/firefox.sh
. $RULES_DIR/firefox-3.5.sh

case $TARGET_ARCH in
i*86-*)
    . $RULES_DIR/flashplayer-adobe-x86.sh
    ;;
*)
    #. $SETS_DIR/packages-gnash.inc
    . $SETS_DIR/packages-swfdec.inc
    ;;
esac

. $RULES_DIR/mplayerplug-in.sh
