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

METACITY_VERSION=2.28.0
METACITY=metacity-${METACITY_VERSION}.tar.bz2
METACITY_MIRROR=http://ftp.acc.umu.se/pub/gnome/sources/metacity/2.28
METACITY_DIR=$BUILD_DIR/metacity-${METACITY_VERSION}
METACITY_ENV="$CROSS_ENV_AC"

build_metacity() {
    test -e "$STATE_DIR/metacity.installed" && return
    banner "Build metacity"
    download $METACITY_MIRROR $METACITY
    extract $METACITY
    apply_patches $METACITY_DIR $METACITY
    pushd $TOP_DIR
    cd $METACITY_DIR
    (
    eval \
	$CROSS_CONF_ENV \
	$METACITY_ENV \
	./configure --build=$BUILD_ARCH --host=$TARGET_ARCH \
	    --prefix=/usr \
	    --sysconfdir=/etc \
	    --disable-gconf \
	    || error
    ) || error "configure"

    make $MAKEARGS || error

    #install_sysroot_files || error

    install_fakeroot_init

    error "update install"

    install_fakeroot_finish || error

    popd
    touch "$STATE_DIR/metacity.installed"
}

build_metacity
