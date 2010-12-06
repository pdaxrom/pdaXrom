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

ZVBI_VERSION=0.2.33
ZVBI=zvbi-${ZVBI_VERSION}.tar.bz2
ZVBI_MIRROR=http://downloads.sourceforge.net/project/zapping/zvbi/0.2.33
ZVBI_DIR=$BUILD_DIR/zvbi-${ZVBI_VERSION}
ZVBI_ENV="$CROSS_ENV_AC"

build_zvbi() {
    test -e "$STATE_DIR/zvbi.installed" && return
    banner "Build zvbi"
    download $ZVBI_MIRROR $ZVBI
    extract $ZVBI
    apply_patches $ZVBI_DIR $ZVBI
    pushd $TOP_DIR
    cd $ZVBI_DIR
    (
    eval \
	$CROSS_CONF_ENV \
	$ZVBI_ENV \
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
    touch "$STATE_DIR/zvbi.installed"
}

build_zvbi
