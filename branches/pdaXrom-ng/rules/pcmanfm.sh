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

PCMANFM=pcmanfm-0.5.tar.gz
PCMANFM_MIRROR=http://downloads.sourceforge.net/pcmanfm
PCMANFM_DIR=$BUILD_DIR/pcmanfm-0.5
PCMANFM_ENV="$CROSS_ENV_AC"

build_pcmanfm() {
    test -e "$STATE_DIR/pcmanfm.installed" && return
    banner "Build pcmanfm"
    download $PCMANFM_MIRROR $PCMANFM
    extract $PCMANFM
    apply_patches $PCMANFM_DIR $PCMANFM
    pushd $TOP_DIR
    cd $PCMANFM_DIR
    (
    eval \
	$CROSS_CONF_ENV \
	$PCMANFM_ENV \
	./configure --build=$BUILD_ARCH --host=$TARGET_ARCH \
	    --prefix=/usr \
	    --sysconfdir=/etc \
	    --x-includes=$TARGET_INC \
	    --x-libraries=$TARGET_LIB \
	    --disable-hal \
	    --disable-superuser-checks
    ) || error "configure"
    
    make $MAKEARGS || error

    $INSTALL -D -m 755 src/pcmanfm $ROOTFS_DIR/usr/bin/pcmanfm || error
    $STRIP $ROOTFS_DIR/usr/bin/pcmanfm
    
    make DESTDIR=$ROOTFS_DIR install-data-am || error

    update-mime-database $ROOTFS_DIR/usr/share/mime

    $INSTALL -D -m 644 $GENERICFS_DIR/pcmanfm/main $ROOTFS_DIR/etc/xdg/pcmanfm/main || error
    $INSTALL -D -m 644 $GENERICFS_DIR/idesk/withatwist.png $ROOTFS_DIR/usr/share/pixmaps/withatwist.png || error

    popd
    touch "$STATE_DIR/pcmanfm.installed"
}

build_pcmanfm
