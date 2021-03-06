. $SETS_DIR/packages-gconf.inc

if [ "$USE_LOGINMANAGER" = "slim" ]; then
    . $RULES_DIR/target-bash.sh
    . $RULES_DIR/slim.sh
fi

case $USE_WINDOWMANAGER in
compiz)
    . $RULES_DIR/libwnck.sh
    . $RULES_DIR/compiz.sh
    ;;
jwm)
    . $RULES_DIR/jwm.sh
    ;;
kahakai)
    . $RULES_DIR/boost.sh
    . $RULES_DIR/kahakai.sh
    ;;
metacity)
    . $RULES_DIR/libtool.sh
    . $RULES_DIR/libcanberra.sh
    . $RULES_DIR/metacity.sh
    ;;
pekwm)
    . $RULES_DIR/sn-monitor.sh
    . $RULES_DIR/pekwm.sh
    . $RULES_DIR/pekwm-themes.sh
    ;;
*)
    . $RULES_DIR/openbox.sh
    ;;
esac

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

case $USE_WEBBROWSER in
midori)
    . $SETS_DIR/packages-midori.inc
    ;;
*)
    . $SETS_DIR/packages-firefox.inc
    ;;
esac

#
# IM
#
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

#
# vlc
#
if [ "$USE_VLC_PLAYER" = "yes" ]; then
. $RULES_DIR/SDL.sh
. $RULES_DIR/libogg.sh
. $RULES_DIR/libvorbis.sh
. $RULES_DIR/speex.sh
. $RULES_DIR/libtheora.sh
. $RULES_DIR/libv4l.sh
. $RULES_DIR/libmad.sh
. $RULES_DIR/SDL_image.sh
. $RULES_DIR/a52dec.sh
. $RULES_DIR/libmpeg2.sh
. $RULES_DIR/libmtp.sh
#. $RULES_DIR/live555.sh
. $RULES_DIR/zvbi.sh
. $RULES_DIR/libdvbpsi5.sh
. $RULES_DIR/libcddb.sh
. $RULES_DIR/libcdio.sh
. $RULES_DIR/popt.sh
. $RULES_DIR/vcdimager.sh
. $RULES_DIR/libupnp.sh
. $RULES_DIR/host_yasm.sh
. $RULES_DIR/x264-snapshot.sh
. $RULES_DIR/libdvdcss.sh
. $RULES_DIR/libdvdread.sh
. $RULES_DIR/libdvdnav.sh
. $RULES_DIR/taglib.sh
. $RULES_DIR/libproxy.sh
. $RULES_DIR/flac.sh
. $RULES_DIR/readline.sh
. $RULES_DIR/lua.sh
. $RULES_DIR/libfribidi.sh
. $RULES_DIR/qt-all-opensource-src.sh
. $RULES_DIR/vlc.sh

#
# Arora
#
#. $RULES_DIR/arora.sh
fi


#
# audioplayer
#
. $SETS_DIR/packages-audacious.inc

#
# Texteditor
#
. $RULES_DIR/leafpad.sh

#
# Image viewer
#
. $RULES_DIR/gpicview.sh

#
# Archiver
#
. $RULES_DIR/unzip.sh
. $RULES_DIR/zip.sh
. $RULES_DIR/unrar.sh
. $RULES_DIR/xarchiver.sh

