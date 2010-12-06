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

ENCHANT_VERSION=1.5.0
ENCHANT=enchant-${ENCHANT_VERSION}.tar.gz
ENCHANT_MIRROR=http://www.abisource.com/downloads/enchant/1.5.0
ENCHANT_DIR=$BUILD_DIR/enchant-${ENCHANT_VERSION}
ENCHANT_ENV="$CROSS_ENV_AC"

build_enchant() {
    test -e "$STATE_DIR/enchant.installed" && return
    banner "Build enchant"
    download $ENCHANT_MIRROR $ENCHANT
    extract $ENCHANT
    apply_patches $ENCHANT_DIR $ENCHANT
    pushd $TOP_DIR
    cd $ENCHANT_DIR
    (
    eval \
	$CROSS_CONF_ENV \
	$ENCHANT_ENV \
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
    touch "$STATE_DIR/enchant.installed"
}

build_enchant
