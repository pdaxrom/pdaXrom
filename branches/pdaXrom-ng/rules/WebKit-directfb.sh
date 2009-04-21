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

#WEBKIT_REVISION=r42583
WEBKIT_REVISION=r39790
WEBKIT=WebKit-${WEBKIT_REVISION}.tar.bz2
WEBKIT_MIRROR=http://builds.nightly.webkit.org/files/trunk/src
WEBKIT_DIR=$BUILD_DIR/WebKit-${WEBKIT_REVISION}
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
    ./autogen.sh
    eval \
	$CROSS_CONF_ENV \
	$WEBKIT_ENV \
	./configure --build=$BUILD_ARCH --host=$TARGET_ARCH \
	    --prefix=/usr \
	    --sysconfdir=/etc \
	    --enable-svg-animation \
	    --with-target=directfb \
	    --disable-video \
	    || error
    ) || error "configure"
    
    make $MAKEARGS || error

    install_sysroot_files || error

    $INSTALL -D -m 644 .libs/libwebkit-1.0.so.2.3.0 $ROOTFS_DIR/usr/lib/libwebkit-1.0.so.2.3.0 || error
    ln -sf libwebkit-1.0.so.2.3.0 $ROOTFS_DIR/usr/lib/libwebkit-1.0.so.2
    ln -sf libwebkit-1.0.so.2.3.0 $ROOTFS_DIR/usr/lib/libwebkit-1.0.so
    $STRIP $ROOTFS_DIR/usr/lib/libwebkit-1.0.so.2.3.0 || error

    popd
    touch "$STATE_DIR/WebKit.installed"
}

build_WebKit
