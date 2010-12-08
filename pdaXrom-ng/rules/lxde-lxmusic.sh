#
# packet template
#
# Copyright (C) 2008 by Alexander Chukov <sash@pdaXrom.org>
#          
# See CREDITS for details about who has contributed to this project.
#
# For further information about the pdaXrom project and license conditions
# see the README file.
#

LXDE_LXMUSIC_VERSION=0.4.4
LXDE_LXMUSIC=lxmusic-${LXDE_LXMUSIC_VERSION}.tar.gz
LXDE_LXMUSIC_MIRROR=http://downloads.sourceforge.net/lxde
LXDE_LXMUSIC_DIR=$BUILD_DIR/lxmusic-${LXDE_LXMUSIC_VERSION}
LXDE_LXMUSIC_ENV="$CROSS_ENV_AC"

build_lxde_lxmusic() {
    test -e "$STATE_DIR/lxde_lxmusic.installed" && return
    banner "Build lxde-lxmusic"
    download $LXDE_LXMUSIC_MIRROR $LXDE_LXMUSIC
    extract $LXDE_LXMUSIC
    apply_patches $LXDE_LXMUSIC_DIR $LXDE_LXMUSIC
    pushd $TOP_DIR
    cd $LXDE_LXMUSIC_DIR
    (
    eval \
	$CROSS_CONF_ENV \
	$LXDE_LXMUSIC_ENV \
	./configure --build=$BUILD_ARCH --host=$TARGET_ARCH \
	    --prefix=/usr \
	    --sysconfdir=/etc \
	    || error
    ) || error "configure"

    make $MAKEARGS || error

    install_fakeroot_init

    install_fakeroot_finish || error

    popd
    touch "$STATE_DIR/lxde_lxmusic.installed"
}

build_lxde_lxmusic
