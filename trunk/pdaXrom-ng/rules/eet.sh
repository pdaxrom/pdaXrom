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

EET_VERSION=1.4.0.beta3
EET=eet-${EET_VERSION}.tar.bz2
EET_MIRROR=http://download.enlightenment.org/releases
EET_DIR=$BUILD_DIR/eet-${EET_VERSION}
EET_ENV="$CROSS_ENV_AC"

build_eet() {
    test -e "$STATE_DIR/eet.installed" && return
    banner "Build eet"
    download $EET_MIRROR $EET
    extract $EET
    apply_patches $EET_DIR $EET
    pushd $TOP_DIR
    cd $EET_DIR
    (
    eval \
	$CROSS_CONF_ENV \
	$EET_ENV \
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
    touch "$STATE_DIR/eet.installed"
}

build_eet
