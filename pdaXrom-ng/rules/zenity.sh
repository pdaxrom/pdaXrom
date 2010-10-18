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

ZENITY_VERSION=2.32.0
ZENITY=zenity-${ZENITY_VERSION}.tar.bz2
ZENITY_MIRROR=http://ftp.gnome.org/pub/gnome/sources/zenity/2.32
ZENITY_DIR=$BUILD_DIR/zenity-${ZENITY_VERSION}
ZENITY_ENV="$CROSS_ENV_AC"

build_zenity() {
    test -e "$STATE_DIR/zenity.installed" && return
    banner "Build zenity"
    download $ZENITY_MIRROR $ZENITY
    extract $ZENITY
    apply_patches $ZENITY_DIR $ZENITY
    pushd $TOP_DIR
    cd $ZENITY_DIR
    (
    eval \
	$CROSS_CONF_ENV \
	$ZENITY_ENV \
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
    touch "$STATE_DIR/zenity.installed"
}

build_zenity
