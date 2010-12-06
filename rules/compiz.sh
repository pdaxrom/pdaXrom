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

COMPIZ_VERSION=0.8.4
COMPIZ=compiz-${COMPIZ_VERSION}.tar.bz2
COMPIZ_MIRROR=http://releases.compiz.org/0.8.4
COMPIZ_DIR=$BUILD_DIR/compiz-${COMPIZ_VERSION}
COMPIZ_ENV="$CROSS_ENV_AC"

build_compiz() {
    test -e "$STATE_DIR/compiz.installed" && return
    banner "Build compiz"
    download $COMPIZ_MIRROR $COMPIZ
    extract $COMPIZ
    apply_patches $COMPIZ_DIR $COMPIZ
    pushd $TOP_DIR
    cd $COMPIZ_DIR
    (
    eval \
	$CROSS_CONF_ENV \
	$COMPIZ_ENV \
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
    touch "$STATE_DIR/compiz.installed"
}

build_compiz
