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

MSTTCOREFONTS_VERSION=1.0
MSTTCOREFONTS_MIRROR=http://downloads.sourceforge.net/sourceforge/corefonts
MSTTCOREFONTS_DIR=$BUILD_DIR/msttcorefonts-$MSTTCOREFONTS_VERSION

build_msttcorefonts() {
    test -e "$STATE_DIR/msttcorefonts.installed" && return
    banner "Build msttcorefonts"
    mkdir -p $MSTTCOREFONTS_DIR
    pushd $TOP_DIR
    cd $MSTTCOREFONTS_DIR

    for f in andale32.exe arial32.exe arialb32.exe comic32.exe courie32.exe georgi32.exe impact32.exe times32.exe trebuc32.exe verdan32.exe wd97vwr32.exe webdin32.exe ; do
	download $MSTTCOREFONTS_MIRROR $f
	cabextract --lowercase  $SRC_DIR/$f
    done
    
    find . -name "*.ttf" | while read f; do
	$INSTALL -D -m 644 $f $ROOTFS_DIR/usr/share/fonts/truetype/$f || error
    done

    mkfontscale $ROOTFS_DIR/usr/share/fonts/truetype || error
    mkfontdir $ROOTFS_DIR/usr/share/fonts/truetype || error
    fc-cache $ROOTFS_DIR/usr/share/fonts/truetype || error

    popd
    touch "$STATE_DIR/msttcorefonts.installed"
}

build_msttcorefonts
