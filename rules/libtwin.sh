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

LIBTWIN=libtwin-0.0.3.tar.gz
LIBTWIN_MIRROR=http://ozlabs.org/~jk/projects/petitboot/downloads
LIBTWIN_DIR=$BUILD_DIR/libtwin-0.0.3
LIBTWIN_ENV="$CROSS_ENV_AC"

build_libtwin() {
    test -e "$STATE_DIR/libtwin.installed" && return
    banner "Build libtwin"
    download $LIBTWIN_MIRROR $LIBTWIN
    extract $LIBTWIN
    apply_patches $LIBTWIN_DIR $LIBTWIN
    pushd $TOP_DIR
    cd $LIBTWIN_DIR
    (
    eval \
	$CROSS_CONF_ENV \
	$LIBTWIN_ENV \
	./configure --build=$BUILD_ARCH --host=$TARGET_ARCH \
	    --prefix=/usr \
	    --sysconfdir=/etc \
	    --enable-shared \
	    --enable-static \
	    --disable-x11 \
	    --disable-altivec \
	    --disable-twin-ttf \
	    || error
    ) || error "configure"
    
    make $MAKEARGS || error

    install_sysroot_files || error

    $INSTALL -D -m 644 libtwin/.libs/libtwin.so.0.0.1 $ROOTFS_DIR/usr/lib/libtwin.so.0.0.1 || error
    ln -sf libtwin.so.0.0.1 $ROOTFS_DIR/usr/lib/libtwin.so.0
    ln -sf libtwin.so.0.0.1 $ROOTFS_DIR/usr/lib/libtwin.so
    $STRIP $ROOTFS_DIR/usr/lib/libtwin.so.0.0.1 || error
    
    popd
    touch "$STATE_DIR/libtwin.installed"
}

build_libtwin
