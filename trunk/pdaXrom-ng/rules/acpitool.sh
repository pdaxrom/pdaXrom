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

ACPITOOL_VERSION=0.5
ACPITOOL=acpitool-${ACPITOOL_VERSION}.tar.bz2
ACPITOOL_MIRROR=http://freeunix.dyndns.org:8000/ftp_site/pub/unix/acpitool
ACPITOOL_DIR=$BUILD_DIR/acpitool-${ACPITOOL_VERSION}
ACPITOOL_ENV="$CROSS_ENV_AC"

build_acpitool() {
    test -e "$STATE_DIR/acpitool.installed" && return
    banner "Build acpitool"
    download $ACPITOOL_MIRROR $ACPITOOL
    extract $ACPITOOL
    apply_patches $ACPITOOL_DIR $ACPITOOL
    pushd $TOP_DIR
    cd $ACPITOOL_DIR
    (
    eval \
	$CROSS_CONF_ENV \
	$ACPITOOL_ENV \
	./configure --build=$BUILD_ARCH --host=$TARGET_ARCH \
	    --prefix=/usr \
	    --sysconfdir=/etc \
	    || error
    ) || error "configure"
    
    make $MAKEARGS || error

    $INSTALL -D -m 755 src/acpitool $ROOTFS_DIR/usr/bin/acpitool || error
    $STRIP $ROOTFS_DIR/usr/bin/acpitool || error

    popd
    touch "$STATE_DIR/acpitool.installed"
}

build_acpitool
