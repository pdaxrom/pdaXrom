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

KEYBOARD_TRAY_VERSION=0.1
KEYBOARD_TRAY=keyboard-tray-${KEYBOARD_TRAY_VERSION}.tar.bz2
KEYBOARD_TRAY_MIRROR=http://wiki.pdaxrom.org/downloads/keyboard-tray
KEYBOARD_TRAY_DIR=$BUILD_DIR/keyboard-tray-${KEYBOARD_TRAY_VERSION}
KEYBOARD_TRAY_ENV="$CROSS_ENV_AC"

build_keyboard_tray() {
    test -e "$STATE_DIR/keyboard_tray.installed" && return
    banner "Build keyboard-tray"
    download $KEYBOARD_TRAY_MIRROR $KEYBOARD_TRAY
    extract $KEYBOARD_TRAY
    apply_patches $KEYBOARD_TRAY_DIR $KEYBOARD_TRAY
    pushd $TOP_DIR
    cd $KEYBOARD_TRAY_DIR
    (
    eval \
	$CROSS_CONF_ENV \
	$KEYBOARD_TRAY_ENV \
	./configure --build=$BUILD_ARCH --host=$TARGET_ARCH \
	    --prefix=/usr \
	    --sysconfdir=/etc \
	    || error
    ) || error "configure"
    
    make $MAKEARGS || error

    make $MAKEARGS DESTDIR=$ROOTFS_DIR install || error

    $STRIP $ROOTFS_DIR/usr/bin/keyboard-tray || error

    popd
    touch "$STATE_DIR/keyboard_tray.installed"
}

build_keyboard_tray
