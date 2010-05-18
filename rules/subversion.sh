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

SUBVERSION_VERSION=1.6.6
SUBVERSION=subversion-${SUBVERSION_VERSION}.tar.bz2
SUBVERSION_MIRROR=http://subversion.tigris.org/downloads
SUBVERSION_DIR=$BUILD_DIR/subversion-${SUBVERSION_VERSION}
SUBVERSION_ENV="$CROSS_ENV_AC"

build_subversion() {
    test -e "$STATE_DIR/subversion.installed" && return
    banner "Build subversion"
    download $SUBVERSION_MIRROR $SUBVERSION
    extract $SUBVERSION
    apply_patches $SUBVERSION_DIR $SUBVERSION
    pushd $TOP_DIR
    cd $SUBVERSION_DIR
    (
    eval \
	$CROSS_CONF_ENV \
	$SUBVERSION_ENV \
	./configure --build=$BUILD_ARCH --host=$TARGET_ARCH \
	    --prefix=/usr \
	    --sysconfdir=/etc \
	    --with-editor=/usr/bin/nano \
	    || error
    ) || error "configure"

    sed -i -e "s|subversion/svnversion/svnversion|svnversion|" Makefile

    make $MAKEARGS || error

    #install_sysroot_files || error

    install_fakeroot_init
    install_fakeroot_finish || error

    popd
    touch "$STATE_DIR/subversion.installed"
}

build_subversion
