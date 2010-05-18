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

GPICVIEW=gpicview-0.1.11.tar.gz
GPICVIEW_MIRROR=http://downloads.sourceforge.net/lxde
GPICVIEW_DIR=$BUILD_DIR/gpicview-0.1.11
GPICVIEW_ENV="$CROSS_ENV_AC"

build_gpicview() {
    test -e "$STATE_DIR/gpicview.installed" && return
    banner "Build gpicview"
    download $GPICVIEW_MIRROR $GPICVIEW
    extract $GPICVIEW
    apply_patches $GPICVIEW_DIR $GPICVIEW
    pushd $TOP_DIR
    cd $GPICVIEW_DIR
    (
    eval \
	$CROSS_CONF_ENV \
	$GPICVIEW_ENV \
	./configure --build=$BUILD_ARCH --host=$TARGET_ARCH \
	    --prefix=/usr \
	    --sysconfdir=/etc \
	    || error
    ) || error "configure"
    
    make $MAKEARGS || error

    $INSTALL -D -m 755 src/gpicview $ROOTFS_DIR/usr/bin/gpicview || error
    $STRIP $ROOTFS_DIR/usr/bin/gpicview
    $INSTALL -D -m 644 gpicview.desktop $ROOTFS_DIR/usr/share/applications/gpicview.desktop || error
    $INSTALL -D -m 644 gpicview.png     $ROOTFS_DIR/usr/share/pixmaps/gpicview.png || error
    make -C data DESTDIR=$ROOTFS_DIR install || error

    popd
    touch "$STATE_DIR/gpicview.installed"
}

build_gpicview
