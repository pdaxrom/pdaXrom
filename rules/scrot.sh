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

SCROT=scrot-0.8.tar.gz
SCROT_MIRROR=http://linuxbrit.co.uk/downloads
SCROT_DIR=$BUILD_DIR/scrot-0.8
SCROT_ENV="$CROSS_ENV_AC"

build_scrot() {
    test -e "$STATE_DIR/scrot.installed" && return
    banner "Build scrot"
    download $SCROT_MIRROR $SCROT
    extract $SCROT
    apply_patches $SCROT_DIR $SCROT
    pushd $TOP_DIR
    cd $SCROT_DIR
    (
    autoreconf -i
    eval \
	$CROSS_CONF_ENV \
	$SCROT_ENV \
	./configure --build=$BUILD_ARCH --host=$TARGET_ARCH \
	    --prefix=/usr \
	    --sysconfdir=/etc \
	    --x-includes=$TARGET_INC \
	    --x-libraries=$TARGET_LIB \
	    || error
    ) || error "configure"
    
    make $MAKEARGS || error

    $INSTALL -D -m 755 src/scrot $ROOTFS_DIR/usr/bin/scrot || error
    $STRIP $ROOTFS_DIR/usr/bin/scrot

    popd
    touch "$STATE_DIR/scrot.installed"
}

build_scrot
