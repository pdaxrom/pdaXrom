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

BOOLSTUFF_VERSION=0.1.12
BOOLSTUFF=boolstuff-${BOOLSTUFF_VERSION}.tar.gz
BOOLSTUFF_MIRROR=http://perso.b2b2c.ca/sarrazip/dev
BOOLSTUFF_DIR=$BUILD_DIR/boolstuff-${BOOLSTUFF_VERSION}
BOOLSTUFF_ENV="$CROSS_ENV_AC"

build_boolstuff() {
    test -e "$STATE_DIR/boolstuff.installed" && return
    banner "Build boolstuff"
    download $BOOLSTUFF_MIRROR $BOOLSTUFF
    extract $BOOLSTUFF
    apply_patches $BOOLSTUFF_DIR $BOOLSTUFF
    pushd $TOP_DIR
    cd $BOOLSTUFF_DIR
    (
    eval \
	$CROSS_CONF_ENV \
	$BOOLSTUFF_ENV \
	./configure --build=$BUILD_ARCH --host=$TARGET_ARCH \
	    --prefix=/usr \
	    --sysconfdir=/etc \
	    || error
    ) || error "configure"

    make $MAKEARGS || error
    install_sysroot_files || error

    install_rootfs_usr_lib src/boolstuff/.libs/libboolstuff-0.1.so.0.0.0
    install_rootfs_usr_bin src/commands/.libs/booldnf

    popd
    touch "$STATE_DIR/boolstuff.installed"
}

build_boolstuff
