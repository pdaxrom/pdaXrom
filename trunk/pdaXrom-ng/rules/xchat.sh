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

XCHAT_VERSION=2.8.8
XCHAT=xchat-${XCHAT_VERSION}.tar.bz2
XCHAT_MIRROR=http://downloads.sourceforge.net/xchat
XCHAT_DIR=$BUILD_DIR/xchat-${XCHAT_VERSION}
XCHAT_ENV="$CROSS_ENV_AC"

build_xchat() {
    test -e "$STATE_DIR/xchat.installed" && return
    banner "Build xchat"
    download $XCHAT_MIRROR $XCHAT
    extract $XCHAT
    apply_patches $XCHAT_DIR $XCHAT
    pushd $TOP_DIR
    cd $XCHAT_DIR
    (
    eval \
	$CROSS_CONF_ENV \
	$XCHAT_ENV \
	./configure --build=$BUILD_ARCH --host=$TARGET_ARCH \
	    --prefix=/usr \
	    --sysconfdir=/etc \
	    --enable-xft \
	    --disable-python \
	    --enable-openssl=$TARGET_BIN_DIR \
	    --disable-perl \
	    --disable-tcl \
	    --disable-dbus \
	    || error
    ) || error "configure"

#    sed -i 's/GtkType/GType/' src/fe-gtk/xtext.{c,h}

    make $MAKEARGS || error

    $INSTALL -D -m 755 src/fe-gtk/xchat $ROOTFS_DIR/usr/bin/xchat || error
    $STRIP $ROOTFS_DIR/usr/bin/xchat

    $INSTALL -D -m 644 xchat.desktop $ROOTFS_DIR/usr/share/applications/xchat.desktop || error
    $INSTALL -D -m 644 xchat.png     $ROOTFS_DIR/usr/share/pixmaps/xchat.png || error

    popd
    touch "$STATE_DIR/xchat.installed"
}

build_xchat
