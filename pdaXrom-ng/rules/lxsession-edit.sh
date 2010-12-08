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

LXSESSION_EDIT_VERSION=0.1.1
LXSESSION_EDIT=lxsession-edit-${LXSESSION_EDIT_VERSION}.tar.gz
LXSESSION_EDIT_MIRROR=http://downloads.sourceforge.net/project/lxde/LXSession%20Edit/lxsession-edit%200.1.1
LXSESSION_EDIT_DIR=$BUILD_DIR/lxsession-edit-${LXSESSION_EDIT_VERSION}
LXSESSION_EDIT_ENV="$CROSS_ENV_AC"

build_lxsession_edit() {
    test -e "$STATE_DIR/lxsession_edit.installed" && return
    banner "Build lxsession-edit"
    download $LXSESSION_EDIT_MIRROR $LXSESSION_EDIT
    extract $LXSESSION_EDIT
    apply_patches $LXSESSION_EDIT_DIR $LXSESSION_EDIT
    pushd $TOP_DIR
    cd $LXSESSION_EDIT_DIR
    (
    eval \
	$CROSS_CONF_ENV \
	$LXSESSION_EDIT_ENV \
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
    touch "$STATE_DIR/lxsession_edit.installed"
}

build_lxsession_edit
