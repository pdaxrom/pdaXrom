#
# packet template
#
# Copyright (C) 2010 by Alexander Chukov <sash@pdaXrom.org>
#
# See CREDITS for details about who has contributed to this project.
#
# For further information about the pdaXrom project and license conditions
# see the README file.
#

EDJE_VERSION=1.0.0.beta3
EDJE=edje-${EDJE_VERSION}.tar.bz2
EDJE_MIRROR=http://download.enlightenment.org/releases
EDJE_DIR=$BUILD_DIR/edje-${EDJE_VERSION}
EDJE_ENV="$CROSS_ENV_AC LUA_CFLAGS=\"-I${TARGET_INC}\" LUA_LIBS=\"-L${TARGET_LIB} -llua\""

build_edje() {
    test -e "$STATE_DIR/edje.installed" && return
    banner "Build edje"
    download $EDJE_MIRROR $EDJE
    extract $EDJE
    apply_patches $EDJE_DIR $EDJE
    pushd $TOP_DIR
    cd $EDJE_DIR
    (
    eval \
	$CROSS_CONF_ENV \
	$EDJE_ENV \
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
    touch "$STATE_DIR/edje.installed"
}

build_edje
