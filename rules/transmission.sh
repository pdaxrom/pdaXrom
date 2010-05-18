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

TRANSMISSION_VERSION=1.80
TRANSMISSION=transmission-${TRANSMISSION_VERSION}.tar.bz2
TRANSMISSION_MIRROR=http://mirrors.m0k.org/transmission/files
TRANSMISSION_DIR=$BUILD_DIR/transmission-${TRANSMISSION_VERSION}
TRANSMISSION_ENV="$CROSS_ENV_AC"

build_transmission() {
    test -e "$STATE_DIR/transmission.installed" && return
    banner "Build transmission"
    download $TRANSMISSION_MIRROR $TRANSMISSION
    extract $TRANSMISSION
    apply_patches $TRANSMISSION_DIR $TRANSMISSION
    pushd $TOP_DIR
    cd $TRANSMISSION_DIR
    (
    eval \
	$CROSS_CONF_ENV \
	$TRANSMISSION_ENV \
	./configure --build=$BUILD_ARCH --host=$TARGET_ARCH \
	    --prefix=/usr \
	    --sysconfdir=/etc \
	    --enable-gtk \
	    --enable-wx=no \
	    --enable-cli=no \
	    --enable-daemon=no \
	    || error
    ) || error "configure"
    
    make $MAKEARGS || error

    make -C gtk/icons DESTDIR=$ROOTFS_DIR install || error
    $INSTALL -D -m 755 gtk/transmission $ROOTFS_DIR/usr/bin/transmission || error
    $STRIP $ROOTFS_DIR/usr/bin/transmission || error
    $INSTALL -D -m 644 gtk/transmission.desktop $ROOTFS_DIR/usr/share/applications/transmission.desktop || error
    $INSTALL -D -m 644 gtk/transmission.png $ROOTFS_DIR/usr/share/pixmaps/transmission.png || error

    popd
    touch "$STATE_DIR/transmission.installed"
}

build_transmission
