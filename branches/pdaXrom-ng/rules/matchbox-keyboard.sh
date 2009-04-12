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

MATCHBOX_KEYBOARD_VERSION=0.1
MATCHBOX_KEYBOARD=matchbox-keyboard-${MATCHBOX_KEYBOARD_VERSION}.tar.bz2
MATCHBOX_KEYBOARD_MIRROR=http://matchbox-project.org/sources/matchbox-keyboard/0.1
MATCHBOX_KEYBOARD_DIR=$BUILD_DIR/matchbox-keyboard-${MATCHBOX_KEYBOARD_VERSION}
MATCHBOX_KEYBOARD_ENV="$CROSS_ENV_AC"

build_matchbox_keyboard() {
    test -e "$STATE_DIR/matchbox_keyboard.installed" && return
    banner "Build matchbox-keyboard"
    download $MATCHBOX_KEYBOARD_MIRROR $MATCHBOX_KEYBOARD
    extract $MATCHBOX_KEYBOARD
    apply_patches $MATCHBOX_KEYBOARD_DIR $MATCHBOX_KEYBOARD
    pushd $TOP_DIR
    cd $MATCHBOX_KEYBOARD_DIR
    (
    eval \
	$CROSS_CONF_ENV \
	$MATCHBOX_KEYBOARD_ENV \
	./configure --build=$BUILD_ARCH --host=$TARGET_ARCH \
	    --prefix=/usr \
	    --sysconfdir=/etc \
	    --enable-cairo \
	    || error
    ) || error "configure"
    
    make $MAKEARGS || error

    make DESTDIR=$ROOTFS_DIR install || error
    $STRIP $ROOTFS_DIR/usr/bin/matchbox-keyboard || error

    popd
    touch "$STATE_DIR/matchbox_keyboard.installed"
}

build_matchbox_keyboard
