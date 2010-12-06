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

LINKS_VERSION=2.3pre1
LINKS=links-${LINKS_VERSION}.tar.bz2
LINKS_MIRROR=http://links.twibright.com/download
LINKS_DIR=$BUILD_DIR/links-${LINKS_VERSION}
LINKS_ENV="$CROSS_ENV_AC"

build_links() {
    test -e "$STATE_DIR/links.installed" && return
    banner "Build links"
    download $LINKS_MIRROR $LINKS
    extract $LINKS
    apply_patches $LINKS_DIR $LINKS
    pushd $TOP_DIR
    cd $LINKS_DIR
    autoreconf -i || error "autoreconf script"
    (
    eval \
	$CROSS_CONF_ENV \
	$LINKS_ENV \
	./configure --build=$BUILD_ARCH --host=$TARGET_ARCH \
	    --prefix=/usr \
	    --sysconfdir=/etc \
	    ${PACKAGE_LINKS_CONF_ARGS} \
	    || error
    ) || error "configure"

    make $MAKEARGS || error

    #install_sysroot_files || error

    install_fakeroot_init
    install_fakeroot_finish || error

    popd
    touch "$STATE_DIR/links.installed"
}

build_links
