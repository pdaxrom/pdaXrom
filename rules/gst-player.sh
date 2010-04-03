#
# packet template
#
# Copyright (C) 2009 by Alexander Chukov <sash@pdaXrom.org>
#
# See CREDITS for details about who has contributed to this project.
#
# For further information about the pdaXrom project and license conditions
# see the README file.
#

GST_PLAYER_VERSION=0.0.0
GST_PLAYER=gst-player-${GST_PLAYER_VERSION}.tar.bz2
GST_PLAYER_MIRROR=http://gst-player.googlecode.com/files
GST_PLAYER_DIR=$BUILD_DIR/gst-player-${GST_PLAYER_VERSION}
GST_PLAYER_ENV="$CROSS_ENV_AC"

build_gst_player() {
    test -e "$STATE_DIR/gst_player.installed" && return
    banner "Build gst-player"
    download $GST_PLAYER_MIRROR $GST_PLAYER
    extract $GST_PLAYER
    apply_patches $GST_PLAYER_DIR $GST_PLAYER
    pushd $TOP_DIR
    cd $GST_PLAYER_DIR

    make $MAKEARGS CC=${CROSS}gcc CFLAGS="-O2 -Wl,-rpath-link,${TARGET_LIB}" || error

    install_rootfs_exec /usr/bin ./gst-player

    popd
    touch "$STATE_DIR/gst_player.installed"
}

build_gst_player
