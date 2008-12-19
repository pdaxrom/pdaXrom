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

XORG_XTERM=xterm-237.tgz
XORG_XTERM_MIRROR=ftp://invisible-island.net/xterm
XORG_XTERM_DIR=$BUILD_DIR/xterm-237
XORG_XTERM_ENV=

build_xorg_xterm() {
    test -e "$STATE_DIR/xorg_xterm-237" && return
    banner "Build $XORG_XTERM"
    download $XORG_XTERM_MIRROR $XORG_XTERM
    extract $XORG_XTERM
    apply_patches $XORG_XTERM_DIR $XORG_XTERM
    pushd $TOP_DIR
    cd $XORG_XTERM_DIR
    (
    eval \
	$CROSS_CONF_ENV \
	$XORG_XTERM_ENV \
	./configure --host=$TARGET_ARCH \
	    --prefix=/usr \
	    --sysconfdir=/etc \
	    --datadir=/usr/share \
	    --x-includes=$TARGET_INC \
	    --x-libraries=$TARGET_LIB \
	    --with-freetype-cflags=\"`freetype-config --cflags`\" \
	    --with-freetype-libs=\"`freetype-config --libs`\" \
	    --disable-imake \
	    || error
    )
    make $MAKEARGS || error

    $INSTALL -D -m 755 xterm $ROOTFS_DIR/usr/bin/xterm || error
    $STRIP $ROOTFS_DIR/usr/bin/xterm

    $INSTALL -D -m 644 xterm.desktop $ROOTFS_DIR/usr/share/applications/xterm.desktop || error

    popd
    touch "$STATE_DIR/xorg_xterm-237"
}

build_xorg_xterm
