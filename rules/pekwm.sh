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

PEKWM_VERSION=0.1.10
PEKWM=pekwm-${PEKWM_VERSION}.tar.bz2
PEKWM_MIRROR=http://pekwm.org/projects/3/files
PEKWM_DIR=$BUILD_DIR/pekwm-${PEKWM_VERSION}
PEKWM_ENV="$CROSS_ENV_AC"

build_pekwm() {
    test -e "$STATE_DIR/pekwm.installed" && return
    banner "Build pekwm"
    download $PEKWM_MIRROR $PEKWM
    extract $PEKWM
    apply_patches $PEKWM_DIR $PEKWM
    pushd $TOP_DIR
    cd $PEKWM_DIR
    (
    eval \
	$CROSS_CONF_ENV \
	$PEKWM_ENV \
	./configure --build=$BUILD_ARCH --host=$TARGET_ARCH \
	    --prefix=/usr \
	    --sysconfdir=/etc \
	    || error
    ) || error "configure"
    
    make $MAKEARGS || error

    make -C data DESTDIR=$ROOTFS_DIR install || error
    $INSTALL -D -m 755 src/pekwm $ROOTFS_DIR/usr/bin/pekwm || error
    $STRIP $ROOTFS_DIR/usr/bin/pekwm || error

    popd
    touch "$STATE_DIR/pekwm.installed"
}

build_pekwm
