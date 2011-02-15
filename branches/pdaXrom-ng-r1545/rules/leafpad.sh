#
# packet template
#
# Copyright (C) 2008 by Alexander Chukov <sash@pdaXrom.org>
#          
# See CREDITS for details about who has contributed to this project.
#
# For further information about the pdaXrom project and license conditions
# see the README file.
#

LEAFPAD=leafpad-0.8.16.tar.gz
LEAFPAD_MIRROR=http://savannah.nongnu.org/download/leafpad
LEAFPAD_DIR=$BUILD_DIR/leafpad-0.8.16
LEAFPAD_ENV="$CROSS_ENV_AC"

build_leafpad() {
    test -e "$STATE_DIR/leafpad.installed" && return
    banner "Build leafpad"
    download $LEAFPAD_MIRROR $LEAFPAD
    extract $LEAFPAD
    apply_patches $LEAFPAD_DIR $LEAFPAD
    pushd $TOP_DIR
    cd $LEAFPAD_DIR
    (
    eval \
	$CROSS_CONF_ENV \
	$LEAFPAD_ENV \
	./configure --build=$BUILD_ARCH --host=$TARGET_ARCH \
	    --prefix=/usr \
	    --sysconfdir=/etc \
	    || error
    ) || error "configure"
    
    make $MAKEARGS || error

    $INSTALL -D -m 755 src/leafpad $ROOTFS_DIR/usr/bin/leafpad || error
    $STRIP $ROOTFS_DIR/usr/bin/leafpad
    
    make -C data DESTDIR=$ROOTFS_DIR install || error

    popd
    touch "$STATE_DIR/leafpad.installed"
}

build_leafpad
