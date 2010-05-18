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

KAHAKAI_VERSION=0.6.2
KAHAKAI=kahakai-${KAHAKAI_VERSION}.tar.bz2
KAHAKAI_MIRROR=http://downloads.sourceforge.net/project/kahakai/kahakai/0.6.2
KAHAKAI_DIR=$BUILD_DIR/kahakai-${KAHAKAI_VERSION}
KAHAKAI_ENV="$CROSS_ENV_AC"

build_kahakai() {
    test -e "$STATE_DIR/kahakai.installed" && return
    banner "Build kahakai"
    download $KAHAKAI_MIRROR $KAHAKAI
    extract $KAHAKAI
    apply_patches $KAHAKAI_DIR $KAHAKAI
    pushd $TOP_DIR
    cd $KAHAKAI_DIR
    (
    eval \
	$CROSS_CONF_ENV \
	$KAHAKAI_ENV \
	./configure --build=$BUILD_ARCH --host=$TARGET_ARCH \
	    --prefix=/usr \
	    --sysconfdir=/etc \
	    --disable-python \
	    || error
    ) || error "configure"

    make $MAKEARGS || error

    #install_sysroot_files || error

    install_fakeroot_init
    install_fakeroot_finish || error

    popd
    touch "$STATE_DIR/kahakai.installed"
}

build_kahakai
