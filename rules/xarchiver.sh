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

XARCHIVER=xarchiver-0.5.2.tar.bz2
XARCHIVER_MIRROR=http://downloads.sourceforge.net/xarchiver
XARCHIVER_DIR=$BUILD_DIR/xarchiver-0.5.2
XARCHIVER_ENV="$CROSS_ENV_AC"

build_xarchiver() {
    test -e "$STATE_DIR/xarchiver.installed" && return
    banner "Build xarchiver"
    download $XARCHIVER_MIRROR $XARCHIVER
    extract $XARCHIVER
    apply_patches $XARCHIVER_DIR $XARCHIVER
    pushd $TOP_DIR
    cd $XARCHIVER_DIR
    (
    eval \
	$CROSS_CONF_ENV \
	$XARCHIVER_ENV \
	./configure --build=$BUILD_ARCH --host=$TARGET_ARCH \
	    --prefix=/usr \
	    --sysconfdir=/etc \
	    --libexecdir=/usr/lib/xarchiver \
	    || error
    ) || error "configure"
    
    make $MAKEARGS || error

    $INSTALL -D -m 755 src/xarchiver $ROOTFS_DIR/usr/bin/xarchiver || error
    $STRIP $ROOTFS_DIR/usr/bin/xarchiver
    make -C icons DESTDIR=$ROOTFS_DIR install || error
    make -C pixmaps DESTDIR=$ROOTFS_DIR install || error
    $INSTALL -D -m 644 xarchiver.desktop $ROOTFS_DIR/usr/share/applications/xarchiver.desktop || error

    popd
    touch "$STATE_DIR/xarchiver.installed"
}

build_xarchiver
