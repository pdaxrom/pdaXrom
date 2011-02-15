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

GEANY_VERSION=0.18
GEANY=geany-${GEANY_VERSION}.tar.bz2
GEANY_MIRROR=http://download.geany.org
GEANY_DIR=$BUILD_DIR/geany-${GEANY_VERSION}
GEANY_ENV="$CROSS_ENV_AC"

build_geany() {
    test -e "$STATE_DIR/geany.installed" && return
    banner "Build geany"
    download $GEANY_MIRROR $GEANY
    extract $GEANY
    apply_patches $GEANY_DIR $GEANY
    pushd $TOP_DIR
    cd $GEANY_DIR
    (
    eval \
	$CROSS_CONF_ENV \
	$GEANY_ENV \
	./configure --build=$BUILD_ARCH --host=$TARGET_ARCH \
	    --prefix=/usr \
	    --sysconfdir=/etc \
	    || error
    ) || error "configure"

    make $MAKEARGS || error

    #install_sysroot_files || error

    install_fakeroot_init
    install_fakeroot_finish || error

    popd
    touch "$STATE_DIR/geany.installed"
}

build_geany
