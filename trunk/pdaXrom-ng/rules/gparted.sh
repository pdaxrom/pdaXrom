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

GPARTED_VERSION=0.5.0
GPARTED=gparted-${GPARTED_VERSION}.tar.bz2
GPARTED_MIRROR=http://downloads.sourceforge.net/project/gparted/gparted/gparted-0.5.0
GPARTED_DIR=$BUILD_DIR/gparted-${GPARTED_VERSION}
GPARTED_ENV="$CROSS_ENV_AC GKSUPROG=ktsuss"

build_gparted() {
    test -e "$STATE_DIR/gparted.installed" && return
    banner "Build gparted"
    download $GPARTED_MIRROR $GPARTED
    extract $GPARTED
    apply_patches $GPARTED_DIR $GPARTED
    pushd $TOP_DIR
    cd $GPARTED_DIR
    (
    autoreconf -i
    eval \
	$CROSS_CONF_ENV \
	$GPARTED_ENV \
	./configure --build=$BUILD_ARCH --host=$TARGET_ARCH \
	    --prefix=/usr \
	    --sysconfdir=/etc \
	    --disable-doc \
	    --disable-scrollkeeper \
	    || error
    ) || error "configure"

    make $MAKEARGS || error

    #install_sysroot_files || error

    install_fakeroot_init
    install_fakeroot_finish || error

    popd
    touch "$STATE_DIR/gparted.installed"
}

build_gparted
