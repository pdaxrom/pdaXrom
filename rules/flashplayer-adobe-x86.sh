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

FLASHPLAYER_ADOBE_X86_VERSION=10
FLASHPLAYER_ADOBE_X86=install_flash_player_${FLASHPLAYER_ADOBE_X86_VERSION}_linux.tar.gz
FLASHPLAYER_ADOBE_X86_MIRROR=http://fpdownload.macromedia.com/get/flashplayer/current
FLASHPLAYER_ADOBE_X86_DIR=$BUILD_DIR/install_flash_player_${FLASHPLAYER_ADOBE_X86_VERSION}_linux
FLASHPLAYER_ADOBE_X86_ENV="$CROSS_ENV_AC"

build_flashplayer_adobe_x86() {
    test -e "$STATE_DIR/flashplayer_adobe_x86.installed" && return
    banner "Build flashplayer-adobe-x86"
    download $FLASHPLAYER_ADOBE_X86_MIRROR $FLASHPLAYER_ADOBE_X86
    extract $FLASHPLAYER_ADOBE_X86
    apply_patches $FLASHPLAYER_ADOBE_X86_DIR $FLASHPLAYER_ADOBE_X86
    pushd $TOP_DIR
    cd $FLASHPLAYER_ADOBE_X86_DIR

    $INSTALL -D -m 644 libflashplayer.so $ROOTFS_DIR/usr/lib/firefox/plugins/libflashplayer.so || error

    popd
    touch "$STATE_DIR/flashplayer_adobe_x86.installed"
}

build_flashplayer_adobe_x86
