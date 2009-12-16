#
# packet template
#
# Copyright (C) 2009 by Adrian Crutchfield <insearchof@inventgen-solutions.com>
#
# See CREDITS for details about who has contributed to this project.
#
# For further information about the pdaXrom project and license conditions
# see the README file.
#

KBD_VERSION=1.15
KBD=kbd-${KBD_VERSION}.tar.bz2
KBD_MIRROR=http://www.kernel.org/pub/linux/utils/kbd
KBD_DIR=$BUILD_DIR/kbd-${KBD_VERSION}
KBD_ENV="$CROSS_ENV_AC"

build_kbd() {
    test -e "$STATE_DIR/kbd.installed" && return
    banner "Build kbd"
    download $KBD_MIRROR $KBD
    extract $KBD
    apply_patches $KBD_DIR $KBD
    pushd $TOP_DIR
    cd $KBD_DIR
    (
    eval \
	$CROSS_CONF_ENV \
	$KBD_ENV \
	./configure --build=$BUILD_ARCH --host=$TARGET_ARCH \
	    --prefix=/usr \
	    --sysconfdir=/etc \
	    || error
    ) || error "configure"
   
    make $MAKEARGS || error
    
    make $MAKEARGS DESTDIR=$PWD/fakeroot install || error

    $INSTALL -D -m 755 $KBD_DIR/fakeroot/usr/bin/loadkeys $ROOTFS_DIR/usr/bin
    $INSTALL -D -m 755 $KBD_DIR/fakeroot/usr/bin/dumpkeys $ROOTFS_DIR/usr/bin
    $INSTALL -D -m 755 $KBD_DIR/fakeroot/usr/bin/showkey $ROOTFS_DIR/usr/bin

    popd
    touch "$STATE_DIR/kbd.installed"
}

build_kbd
