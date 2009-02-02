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

OPENBOX=openbox-3.4.7.2.tar.gz
OPENBOX_MIRROR=http://icculus.org/openbox/releases
OPENBOX_DIR=$BUILD_DIR/openbox-3.4.7.2
OPENBOX_ENV="$CROSS_ENV_AC"

build_openbox() {
    test -e "$STATE_DIR/openbox.installed" && return
    banner "Build openbox"
    download $OPENBOX_MIRROR $OPENBOX
    extract $OPENBOX
    apply_patches $OPENBOX_DIR $OPENBOX
    pushd $TOP_DIR
    cd $OPENBOX_DIR
    (
    eval \
	$CROSS_CONF_ENV \
	$OPENBOX_ENV \
	./configure --build=$BUILD_ARCH --host=$TARGET_ARCH \
	    --prefix=/usr \
	    --sysconfdir=/etc \
	    --x-includes=$TARGET_INC \
	    --x-libraries=$TARGET_LIB
    ) || error "configure"

    chmod 755 install-sh
    
    make $MAKEARGS || error

    $INSTALL -D -m 644 data/menu.xml 	$ROOTFS_DIR/etc/xdg/openbox/menu.xml || error
    $INSTALL -D -m 644 data/rc.xml	$ROOTFS_DIR/etc/xdg/openbox/rc.xml || error
    $INSTALL -D -m 755 openbox/.libs/openbox $ROOTFS_DIR/usr/bin/openbox || error
    $STRIP $ROOTFS_DIR/usr/bin/openbox
    $INSTALL -D -m 644 parser/.libs/libobparser.so.21.0.2 $ROOTFS_DIR/usr/lib/libobparser.so.21.0.2 || error
    ln -sf libobparser.so.21.0.2 $ROOTFS_DIR/usr/lib/libobparser.so.21
    ln -sf libobparser.so.21.0.2 $ROOTFS_DIR/usr/lib/libobparser.so
    $STRIP $ROOTFS_DIR/usr/lib/libobparser.so.21.0.2
    $INSTALL -D -m 644 render/.libs/libobrender.so.21.0.2 $ROOTFS_DIR/usr/lib/libobrender.so.21.0.2 || error
    ln -sf libobrender.so.21.0.2 $ROOTFS_DIR/usr/lib/libobrender.so.21
    ln -sf libobrender.so.21.0.2 $ROOTFS_DIR/usr/lib/libobrender.so
    $STRIP $ROOTFS_DIR/usr/lib/libobrender.so.21.0.2
    $INSTALL -D -m 644 data/openbox.png $ROOTFS_DIR/usr/share/pixmaps/openbox.png || error
    $INSTALL -D -m 755 data/xsession/openbox-session $ROOTFS_DIR/usr/bin/openbox-session || error
    $INSTALL -D -m 644 data/xsession/openbox.desktop $ROOTFS_DIR//usr/share/xsessions/openbox.desktop || error
    $INSTALL -D -m 644 themes/Clearlooks/openbox-3/themerc $ROOTFS_DIR/usr/share/themes/Clearlooks/openbox-3/themerc || error

    $INSTALL -D -m 644 $GENERICFS_DIR/openbox/autostart.sh $ROOTFS_DIR/etc/xdg/openbox/autostart.sh || error

    popd
    touch "$STATE_DIR/openbox.installed"
}

build_openbox
