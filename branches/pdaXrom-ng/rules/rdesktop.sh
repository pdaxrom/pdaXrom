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

RDESKTOP=rdesktop-1.6.0.tar.gz
RDESKTOP_MIRROR=http://prdownloads.sourceforge.net/rdesktop
RDESKTOP_DIR=$BUILD_DIR/rdesktop-1.6.0
RDESKTOP_ENV=

build_rdesktop() {
    test -e "$STATE_DIR/rdesktop-1.6.0" && return
    banner "Build $RDESKTOP"
    download $RDESKTOP_MIRROR $RDESKTOP
    extract $RDESKTOP
    apply_patches $RDESKTOP_DIR $RDESKTOP
    pushd $TOP_DIR
    cd $RDESKTOP_DIR
    (
    eval \
	$CROSS_CONF_ENV \
	$RDESKTOP_ENV \
	./configure --build=$BUILD_ARCH --host=$TARGET_ARCH \
	    --prefix=/usr \
	    --sysconfdir=/etc \
	    --with-sound=alsa \
	    --x-includes=$TARGET_INC \
	    --x-libraries=$TARGET_LIB \
	    --oldincludedir=$TARGET_INC \
	    --with-openssl=$TARGET_BIN_DIR \
	    || error
    )
    make $MAKEARGS || error

    $INSTALL -D -m 755 rdesktop $ROOTFS_DIR/usr/bin/rdesktop || error
    $STRIP $ROOTFS_DIR/usr/bin/rdesktop

    popd
    touch "$STATE_DIR/rdesktop-1.6.0"
}

build_rdesktop
