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

LXDE_LXSESSION_VERSION=0.4.5
LXDE_LXSESSION=lxsession-${LXDE_LXSESSION_VERSION}.tar.gz
LXDE_LXSESSION_MIRROR=http://downloads.sourceforge.net/project/lxde/LXSession%20%28session%20manager%29/LXSession%200.4.5
LXDE_LXSESSION_DIR=$BUILD_DIR/lxsession-${LXDE_LXSESSION_VERSION}
LXDE_LXSESSION_ENV="$CROSS_ENV_AC"

build_lxde_lxsession() {
    test -e "$STATE_DIR/lxde_lxsession.installed" && return
    banner "Build lxde-lxsession"
    download $LXDE_LXSESSION_MIRROR $LXDE_LXSESSION
    extract $LXDE_LXSESSION
    apply_patches $LXDE_LXSESSION_DIR $LXDE_LXSESSION
    pushd $TOP_DIR
    cd $LXDE_LXSESSION_DIR
    (
    eval \
	$CROSS_CONF_ENV \
	$LXDE_LXSESSION_ENV \
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
    touch "$STATE_DIR/lxde_lxsession.installed"
}

build_lxde_lxsession
