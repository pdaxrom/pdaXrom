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

SWFDEC_VERSION=0.9.2
SWFDEC=swfdec-${SWFDEC_VERSION}.tar.gz
SWFDEC_MIRROR=http://swfdec.freedesktop.org/download/swfdec/0.9
SWFDEC_DIR=$BUILD_DIR/swfdec-${SWFDEC_VERSION}
SWFDEC_ENV="$CROSS_ENV_AC"

build_swfdec() {
    test -e "$STATE_DIR/swfdec.installed" && return
    banner "Build swfdec"
    download $SWFDEC_MIRROR $SWFDEC
    extract $SWFDEC
    apply_patches $SWFDEC_DIR $SWFDEC
    pushd $TOP_DIR
    cd $SWFDEC_DIR
    (
    eval \
	$CROSS_CONF_ENV \
	$SWFDEC_ENV \
	./configure --build=$BUILD_ARCH --host=$TARGET_ARCH \
	    --prefix=/usr \
	    --sysconfdir=/etc \
	    || error
    ) || error "configure"

    make $MAKEARGS || error

    install_sysroot_files || error

    install_fakeroot_init

    install_fakeroot_usr_bin player/.libs/swfplay

    install_fakeroot_finish || error

    popd
    touch "$STATE_DIR/swfdec.installed"
}

build_swfdec
