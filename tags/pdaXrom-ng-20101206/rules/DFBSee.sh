#
# packet template
#
# Copyright (C) 2010 by Marina Popova <marika@tusur.info>
#
# See CREDITS for details about who has contributed to this project.
#
# For further information about the pdaXrom project and license conditions
# see the README file.
#

DFBSEE_VERSION=0.7.4
DFBSEE=DFBSee-${DFBSEE_VERSION}.tar.gz
DFBSEE_MIRROR=http://www.directfb.org/downloads/Programs
DFBSEE_DIR=$BUILD_DIR/DFBSee-${DFBSEE_VERSION}
DFBSEE_ENV="$CROSS_ENV_AC"

build_DFBSee() {
    test -e "$STATE_DIR/DFBSee.installed" && return
    banner "Build DFBSee"
    download $DFBSEE_MIRROR $DFBSEE
    extract $DFBSEE
    apply_patches $DFBSEE_DIR $DFBSEE
    pushd $TOP_DIR
    cd $DFBSEE_DIR
    (
    eval \
	$CROSS_CONF_ENV \
	$DFBSEE_ENV \
	./configure --build=$BUILD_ARCH --host=$TARGET_ARCH \
	    --prefix=/usr \
	    --sysconfdir=/etc \
	    || error
    ) || error "configure"

    make $MAKEARGS CC=${CROSS}gcc  || error

    #install_sysroot_files || error

    install_fakeroot_init
    install_fakeroot_finish || error

    popd
    touch "$STATE_DIR/DFBSee.installed"
}

build_DFBSee
