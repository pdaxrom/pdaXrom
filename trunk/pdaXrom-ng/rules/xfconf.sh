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

XFCONF_VERSION=4.7.4
XFCONF=xfconf-${XFCONF_VERSION}.tar.bz2
XFCONF_MIRROR=http://archive.xfce.org/src/xfce/xfconf/4.7
XFCONF_DIR=$BUILD_DIR/xfconf-${XFCONF_VERSION}
XFCONF_ENV="$CROSS_ENV_AC"

build_xfconf() {
    test -e "$STATE_DIR/xfconf.installed" && return
    banner "Build xfconf"
    download $XFCONF_MIRROR $XFCONF
    extract $XFCONF
    apply_patches $XFCONF_DIR $XFCONF
    pushd $TOP_DIR
    cd $XFCONF_DIR
    (
    eval \
	$CROSS_CONF_ENV \
	$XFCONF_ENV \
	./configure --build=$BUILD_ARCH --host=$TARGET_ARCH \
	    --prefix=/usr \
	    --sysconfdir=/etc \
	    --disable-perl-bindings \
	    || error
    ) || error "configure"

    make $MAKEARGS || error

    install_sysroot_files || error

    install_fakeroot_init

    install_fakeroot_finish || error

    popd
    touch "$STATE_DIR/xfconf.installed"
}

build_xfconf
