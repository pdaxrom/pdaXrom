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

TUMBLER_VERSION=0.1.5
TUMBLER=tumbler-${TUMBLER_VERSION}.tar.bz2
TUMBLER_MIRROR=http://archive.xfce.org/src/apps/tumbler/0.1
TUMBLER_DIR=$BUILD_DIR/tumbler-${TUMBLER_VERSION}
TUMBLER_ENV="$CROSS_ENV_AC"

build_tumbler() {
    test -e "$STATE_DIR/tumbler.installed" && return
    banner "Build tumbler"
    download $TUMBLER_MIRROR $TUMBLER
    extract $TUMBLER
    apply_patches $TUMBLER_DIR $TUMBLER
    pushd $TOP_DIR
    cd $TUMBLER_DIR
    (
    eval \
	$CROSS_CONF_ENV \
	$TUMBLER_ENV \
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
    touch "$STATE_DIR/tumbler.installed"
}

build_tumbler
