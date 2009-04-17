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

MIDORI=midori-0.1.1.tar.bz2
MIDORI_MIRROR=http://goodies.xfce.org/releases/midori
MIDORI_DIR=$BUILD_DIR/midori-0.1.1
MIDORI_ENV="$CROSS_ENV_AC"

build_midori() {
    test -e "$STATE_DIR/midori.installed" && return
    banner "Build midori"
    download $MIDORI_MIRROR $MIDORI
    extract $MIDORI
    apply_patches $MIDORI_DIR $MIDORI
    pushd $TOP_DIR
    cd $MIDORI_DIR
    (
    ./legacy.sh
    make distclean
    eval \
	$CROSS_CONF_ENV \
	$MIDORI_ENV \
	./configure --build=$BUILD_ARCH --host=$TARGET_ARCH \
	    --prefix=/usr \
	    --sysconfdir=/etc \
	    || error
	ln -sf `which intltool-merge` ./intltool-merge
    ) || error "configure"
    
    make $MAKEARGS || error

    $INSTALL -D -m 755 midori/midori $ROOTFS_DIR/usr/bin/midori || error
    $STRIP $ROOTFS_DIR/usr/bin/midori

    $INSTALL -D -m 644 midori.desktop $ROOTFS_DIR/usr/share/applications/midori.desktop || error
    
    $INSTALL -D -m 644 icons/16x16/extension.png $ROOTFS_DIR/usr/share/icons/hicolor/16x16/categories/extension.png
    $INSTALL -D -m 644 icons/16x16/midori.png 	 $ROOTFS_DIR/usr/share/icons/hicolor/16x16/apps/midori.png
    $INSTALL -D -m 644 icons/16x16/news-feed.png $ROOTFS_DIR/usr/share/icons/hicolor/16x16/status/news-feed.png

    $INSTALL -D -m 644 icons/22x22/extension.png $ROOTFS_DIR/usr/share/icons/hicolor/22x22/categories/extension.png
    $INSTALL -D -m 644 icons/22x22/midori.png 	 $ROOTFS_DIR/usr/share/icons/hicolor/22x22/apps/midori.png
    $INSTALL -D -m 644 icons/22x22/news-feed.png $ROOTFS_DIR/usr/share/icons/hicolor/22x22/status/news-feed.png

    $INSTALL -D -m 644 icons/scalable/extension.svg 	$ROOTFS_DIR/usr/share/icons/hicolor/scalable/categories/extension.svg
    $INSTALL -D -m 644 icons/scalable/midori.svg  	$ROOTFS_DIR/usr/share/icons/hicolor/scalable/apps/midori.svg
    $INSTALL -D -m 644 icons/scalable/news-feed.svg 	$ROOTFS_DIR/usr/share/icons/hicolor/scalable/status/news-feed.svg

    popd
    touch "$STATE_DIR/midori.installed"
}

build_midori
