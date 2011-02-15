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

FIGLET=figlet222.tar.gz
FIGLET_MIRROR=ftp://ftp.figlet.org/pub/figlet/program/unix
FIGLET_DIR=$BUILD_DIR/figlet222
FIGLET_ENV="$CROSS_ENV_AC"

build_figlet() {
    test -e "$STATE_DIR/figlet.installed" && return
    banner "Build figlet"
    download $FIGLET_MIRROR $FIGLET
    extract $FIGLET
    apply_patches $FIGLET_DIR $FIGLET
    pushd $TOP_DIR
    cd $FIGLET_DIR
    
    make $MAKEARGS CC=${CROSS}gcc DEFAULTFONTDIR=/usr/share/figlet/fonts || error
    
    $INSTALL -D -m 755 figlet $ROOTFS_DIR/usr/bin/figlet || error
    $STRIP $ROOTFS_DIR/usr/bin/figlet || error
    $INSTALL -D -m 644 fonts/standard.flf $ROOTFS_DIR/usr/share/figlet/fonts/standard.flf || error

    popd
    touch "$STATE_DIR/figlet.installed"
}

build_figlet
