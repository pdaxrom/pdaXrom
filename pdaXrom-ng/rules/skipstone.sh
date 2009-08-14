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

SKIPSTONE=skipstone-1.0.1.tar.gz
SKIPSTONE_MIRROR=http://www.muhri.net/skipstone
SKIPSTONE_DIR=$BUILD_DIR/skipstone-1.0.1
SKIPSTONE_ENV="$CROSS_ENV_AC"

build_skipstone() {
    test -e "$STATE_DIR/skipstone.installed" && return
    banner "Build skipstone"
    download $SKIPSTONE_MIRROR $SKIPSTONE
    extract $SKIPSTONE
    apply_patches $SKIPSTONE_DIR $SKIPSTONE
    pushd $TOP_DIR
    cd $SKIPSTONE_DIR
#    (
#    eval \
#	$CROSS_CONF_ENV \
#	$SKIPSTONE_ENV \
#	./configure --build=$BUILD_ARCH --host=$TARGET_ARCH \
#	    --prefix=/usr \
#	    --sysconfdir=/etc \
#	    || error
#    ) || error "configure"

    (    
    eval \
	$CROSS_CONF_ENV \
	$SKIPSTONE_ENV \
	make -C src -f Makefile.webkit CC=${CROSS}gcc CXX=${CROSS}g++ STRIP=${CROSS}strip PREFIX=/usr prefix=/usr \
	    OPT_LDFLAGS="-Wl,-rpath-link,$TARGET_BIN_DIR/lib"
    ) || error
    
    $INSTALL -D -m 755 src/skipstone-bin-webkit $ROOTFS_DIR/usr/bin/skipstone-bin-webkit || error
    $STRIP $ROOTFS_DIR/usr/bin/skipstone-bin-webkit
    ln -sf skipstone-bin-webkit $ROOTFS_DIR/usr/bin/skipstone
    $INSTALL -D -m 755 src/skipdownload $ROOTFS_DIR/usr/bin/skipdownload || error
    $STRIP $ROOTFS_DIR/usr/bin/skipdownload
    $INSTALL -d $ROOTFS_DIR/usr/share/skipstone/pixmaps/default
    $INSTALL -c -m 644 pixmaps/*.png $ROOTFS_DIR/usr/share/skipstone/pixmaps/default || error
    $INSTALL -c -m 644 pixmaps/*.gif $ROOTFS_DIR/usr/share/skipstone/pixmaps/default || error

    popd
    touch "$STATE_DIR/skipstone.installed"
}

build_skipstone
