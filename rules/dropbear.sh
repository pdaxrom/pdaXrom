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

DROPBEAR=dropbear-0.52.tar.bz2
DROPBEAR_MIRROR=http://matt.ucc.asn.au/dropbear/releases
DROPBEAR_DIR=$BUILD_DIR/dropbear-0.52
DROPBEAR_ENV=

build_dropbear() {
    test -e "$STATE_DIR/dropbear-0.52" && return
    banner "Build $DROPBEAR"
    download $DROPBEAR_MIRROR $DROPBEAR
    extract $DROPBEAR
    apply_patches $DROPBEAR_DIR $DROPBEAR
    pushd $TOP_DIR
    cd $DROPBEAR_DIR
    (
    eval \
	$CROSS_CONF_ENV \
	 $DROPBEAR_ENV \
	./configure --build=$BUILD_ARCH --host=$TARGET_ARCH \
	    --prefix=/usr \
	    --sysconfdir=/etc || error
    )
    make $MAKEARGS PROGRAMS="dropbear dbclient dropbearkey dropbearconvert scp" || error

    $STRIP dropbear dbclient dropbearkey dropbearconvert scp
    
    $INSTALL -m 755 dbclient dropbearkey dropbearconvert scp $ROOTFS_DIR/usr/bin/
    $INSTALL -m 755 dropbear $ROOTFS_DIR/usr/sbin/
    $INSTALL -m 755 $GENERICFS_DIR/etc/init.d/dropbear $ROOTFS_DIR/etc/init.d/
    install_rc_start dropbear 50
    install_rc_stop  dropbear 50
    mkdir -p $ROOTFS_DIR/etc/dropbear

    popd
    touch "$STATE_DIR/dropbear-0.52"
}

build_dropbear
