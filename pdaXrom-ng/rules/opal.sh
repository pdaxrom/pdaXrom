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

OPAL_VERSION=3.6.6
OPAL=opal-${OPAL_VERSION}.tar.gz
OPAL_MIRROR=http://www.ekiga.org/admin/downloads/latest/sources/ekiga_3.2.6
OPAL_DIR=$BUILD_DIR/opal-${OPAL_VERSION}
OPAL_ENV="$CROSS_ENV_AC"

build_opal() {
    test -e "$STATE_DIR/opal.installed" && return
    banner "Build opal"
    download $OPAL_MIRROR $OPAL
    extract $OPAL
    apply_patches $OPAL_DIR $OPAL
    pushd $TOP_DIR
    cd $OPAL_DIR
    (
    eval \
	$CROSS_CONF_ENV \
	$OPAL_ENV \
	./configure --build=$BUILD_ARCH --host=$TARGET_ARCH \
	    --prefix=/usr \
	    --sysconfdir=/etc \
	    || error
    ) || error "configure"
    
    make $MAKEARGS || error

    install_sysroot_files || error

    install_fakeroot_init
    install_fakeroot_finish || error

    popd
    touch "$STATE_DIR/opal.installed"
}

build_opal
