#!/bin/sh

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
    #. ./sets/packages-gnash.inc
    . ./sets/packages-swfdec.inc
    ;;
esac
