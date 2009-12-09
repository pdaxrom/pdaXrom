. $SETS_DIR/packages-webkit.inc

#
# midori
#
. $RULES_DIR/libunique.sh
. $RULES_DIR/midori.sh

case $TARGET_ARCH in
i*86-*)
    . $RULES_DIR/nspr.sh
    . $RULES_DIR/nss.sh
    . $RULES_DIR/flashplayer-adobe-x86.sh
    ;;
*)
    #. $SETS_DIR/packages-gnash.inc
    . $SETS_DIR/packages-swfdec.inc
    ;;
esac

#. $RULES_DIR/mplayerplug-in.sh
