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

FBGRAB=fbgrab-1.0.tar.gz
FBGRAB_MIRROR=http://hem.bredband.net/gmogmo/fbgrab
FBGRAB_DIR=$BUILD_DIR/fbgrab-1.0
FBGRAB_ENV="$CROSS_ENV_AC"

build_fbgrab() {
    test -e "$STATE_DIR/fbgrab.installed" && return
    banner "Build fbgrab"
    download $FBGRAB_MIRROR $FBGRAB
    extract $FBGRAB
    apply_patches $FBGRAB_DIR $FBGRAB
    pushd $TOP_DIR
    cd $FBGRAB_DIR
    
    ${CROSS}gcc -O2 fbgrab.c -o fbgrab -L$TARGET_LIB -lpng -lz || error
    $INSTALL -D -m 755 fbgrab $ROOTFS_DIR/usr/bin/fbgrab || error
    $STRIP $ROOTFS_DIR/usr/bin/fbgrab || error

    popd
    touch "$STATE_DIR/fbgrab.installed"
}

build_fbgrab
