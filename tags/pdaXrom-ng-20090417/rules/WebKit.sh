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

WEBKIT=WebKit-r39474.tar.bz2
WEBKIT_MIRROR=http://builds.nightly.webkit.org/files/trunk/src
WEBKIT_DIR=$BUILD_DIR/WebKit-r39474
WEBKIT_ENV="$CROSS_ENV_AC"

build_WebKit() {
    test -e "$STATE_DIR/WebKit.installed" && return
    banner "Build WebKit"
    download $WEBKIT_MIRROR $WEBKIT
    extract $WEBKIT
    apply_patches $WEBKIT_DIR $WEBKIT
    pushd $TOP_DIR
    cd $WEBKIT_DIR
    (
    autoreconf -i
    eval \
	$CROSS_CONF_ENV \
	$WEBKIT_ENV \
	./configure --build=$BUILD_ARCH --host=$TARGET_ARCH \
	    --prefix=/usr \
	    --sysconfdir=/etc \
	    --enable-svg-animation \
	    || error
    ) || error "configure"
    
    make $MAKEARGS || error

    install_sysroot_files || error

    $INSTALL -D -m 644 .libs/libwebkit-1.0.so.1.0.0 $ROOTFS_DIR/usr/lib/libwebkit-1.0.so.1.0.0 || error
    ln -sf libwebkit-1.0.so.1.0.0 $ROOTFS_DIR/usr/lib/libwebkit-1.0.so.1
    ln -sf libwebkit-1.0.so.1.0.0 $ROOTFS_DIR/usr/lib/libwebkit-1.0.so
    $STRIP $ROOTFS_DIR/usr/lib/libwebkit-1.0.so.1.0.0 || error

    popd
    touch "$STATE_DIR/WebKit.installed"
}

build_WebKit
