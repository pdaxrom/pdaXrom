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

EPDFVIEW_VERSION=0.1.6
EPDFVIEW=epdfview-${EPDFVIEW_VERSION}.tar.bz2
EPDFVIEW_MIRROR=http://trac.emma-soft.com/epdfview/chrome/site/releases
EPDFVIEW_DIR=$BUILD_DIR/epdfview-${EPDFVIEW_VERSION}
EPDFVIEW_ENV="$CROSS_ENV_AC"

build_epdfview() {
    test -e "$STATE_DIR/epdfview.installed" && return
    banner "Build epdfview"
    download $EPDFVIEW_MIRROR $EPDFVIEW
    extract $EPDFVIEW
    apply_patches $EPDFVIEW_DIR $EPDFVIEW
    pushd $TOP_DIR
    cd $EPDFVIEW_DIR
    (
    eval \
	$CROSS_CONF_ENV \
	$EPDFVIEW_ENV \
	./configure --build=$BUILD_ARCH --host=$TARGET_ARCH \
	    --prefix=/usr \
	    --sysconfdir=/etc \
	    --with-cups=no \
	    || error
    ) || error "configure"
    
    make $MAKEARGS || error

    $INSTALL -D -m 755 src/epdfview $ROOTFS_DIR/usr/bin/epdfview || error
    $STRIP $ROOTFS_DIR/usr/bin/epdfview

    $INSTALL -D -m 644 $GENERICFS_DIR/epdfview/gnome-pdf.png $ROOTFS_DIR/usr/share/pixmaps/gnome-pdf.png || error

    make -C data DESTDIR=$ROOTFS_DIR install || error

    popd
    touch "$STATE_DIR/epdfview.installed"
}

build_epdfview
