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

IDESK=idesk-0.7.5.tar.bz2
IDESK_MIRROR=http://downloads.sourceforge.net/idesk
IDESK_DIR=$BUILD_DIR/idesk-0.7.5
IDESK_ENV="$CROSS_ENV_AC"

build_idesk() {
    test -e "$STATE_DIR/idesk.installed" && return
    banner "Build idesk"
    download $IDESK_MIRROR $IDESK
    extract $IDESK
    apply_patches $IDESK_DIR $IDESK
    pushd $TOP_DIR
    cd $IDESK_DIR
    (
    eval \
	$CROSS_CONF_ENV \
	$IDESK_ENV \
	./configure --build=$BUILD_ARCH --host=$TARGET_ARCH \
	    --prefix=/usr \
	    --sysconfdir=/etc \
	    --x-includes=$TARGET_INC \
	    --x-libraries=$TARGET_LIB \
	    --enable-libsn \
	    || error
    ) || error "configure"
    
    make $MAKEARGS || error

    $INSTALL -D -m 755 src/idesk $ROOTFS_DIR/usr/bin/idesk || error
    $STRIP $ROOTFS_DIR/usr/bin/idesk

    $INSTALL -D -m 644 examples/folder_home.xpm $ROOTFS_DIR/usr/share/idesk/folder_home.xpm || error
    $INSTALL -D -m 644 $GENERICFS_DIR/idesk/default.lnk $ROOTFS_DIR/usr/share/idesk/default.lnk || error
    $INSTALL -D -m 644 $GENERICFS_DIR/idesk/dot.ideskrc $ROOTFS_DIR/usr/share/idesk/dot.ideskrc || error
    $INSTALL -D -m 644 $GENERICFS_DIR/wallpapers/withatwist.png $ROOTFS_DIR/usr/share/idesk/withatwist.png || error

    popd
    touch "$STATE_DIR/idesk.installed"
}

build_idesk
