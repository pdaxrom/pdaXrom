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

CLEARPLAYER_VERSION=0.9
CLEARPLAYER=clearplayer-${CLEARPLAYER_VERSION}.tar.bz2
CLEARPLAYER_MIRROR=http://www.mplayerhq.hu/MPlayer/skins
CLEARPLAYER_DIR=$BUILD_DIR/clearplayer
CLEARPLAYER_ENV="$CROSS_ENV_AC"

build_clearplayer() {
    test -e "$STATE_DIR/clearplayer.installed" && return
    banner "Build clearplayer"
    download $CLEARPLAYER_MIRROR $CLEARPLAYER
    extract $CLEARPLAYER
    apply_patches $CLEARPLAYER_DIR $CLEARPLAYER

    rm -rf $ROOTFS_DIR/usr/share/mplayer/skins/clearplayer
    rm -f $ROOTFS_DIR/usr/share/mplayer/skins/default
    cp -a $CLEARPLAYER_DIR $ROOTFS_DIR/usr/share/mplayer/skins || error
    rm -f $ROOTFS_DIR/usr/share/mplayer/skins/clearplayer/.pdaXrom-ng-patched
    ln -sf clearplayer $ROOTFS_DIR/usr/share/mplayer/skins/default
    ln -sf ../fonts/truetype/Vera.ttf $ROOTFS_DIR/usr/share/mplayer/subfont.ttf

    touch "$STATE_DIR/clearplayer.installed"
}

build_clearplayer
