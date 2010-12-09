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

UPOWER_VERSION=0.9.7
UPOWER=upower-${UPOWER_VERSION}.tar.bz2
UPOWER_MIRROR=http://upower.freedesktop.org/releases
UPOWER_DIR=$BUILD_DIR/upower-${UPOWER_VERSION}
UPOWER_ENV="$CROSS_ENV_AC"

build_upower() {
    test -e "$STATE_DIR/upower.installed" && return
    banner "Build upower"
    download $UPOWER_MIRROR $UPOWER
    extract $UPOWER
    apply_patches $UPOWER_DIR $UPOWER
    pushd $TOP_DIR
    cd $UPOWER_DIR
    (
    eval \
	$CROSS_CONF_ENV \
	$UPOWER_ENV \
	./configure --build=$BUILD_ARCH --host=$TARGET_ARCH \
	    --prefix=/usr \
	    --sysconfdir=/etc \
	    --libexecdir=/usr/lib/upower \
	    || error
    ) || error "configure"

    make $MAKEARGS || error

    #install_sysroot_files || error

    install_fakeroot_init

    install_fakeroot_finish || error

    popd
    touch "$STATE_DIR/upower.installed"
}

build_upower
