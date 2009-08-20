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

EINA_VERSION=0.8.0
EINA=eina-${EINA_VERSION}.tar.gz
EINA_MIRROR=http://downloads.sourceforge.net/eina
EINA_DIR=$BUILD_DIR/eina-${EINA_VERSION}
EINA_ENV="$CROSS_ENV_AC"

build_eina() {
    test -e "$STATE_DIR/eina.installed" && return
    banner "Build eina"
    download $EINA_MIRROR $EINA
    extract $EINA
    apply_patches $EINA_DIR $EINA
    pushd $TOP_DIR
    cd $EINA_DIR
    (
    eval \
	$CROSS_CONF_ENV \
	$EINA_ENV \
	./configure --build=$BUILD_ARCH --host=$TARGET_ARCH \
	    --prefix=/usr \
	    --sysconfdir=/etc \
	    || error
    ) || error "configure"

    make $MAKEARGS || error

    #install_sysroot_files || error

    install_fakeroot_init || error
    install_fakeroot_finish || error

    popd
    touch "$STATE_DIR/eina.installed"
}

build_eina
