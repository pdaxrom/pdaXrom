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

TALLOC_VERSION=2.0.1
TALLOC=talloc-${TALLOC_VERSION}.tar.gz
TALLOC_MIRROR=http://samba.org/ftp/talloc
TALLOC_DIR=$BUILD_DIR/talloc-${TALLOC_VERSION}
TALLOC_ENV="$CROSS_ENV_AC"

build_talloc() {
    test -e "$STATE_DIR/talloc.installed" && return
    banner "Build talloc"
    download $TALLOC_MIRROR $TALLOC
    extract $TALLOC
    apply_patches $TALLOC_DIR $TALLOC
    pushd $TOP_DIR
    cd $TALLOC_DIR
    (
    eval \
	$CROSS_CONF_ENV \
	$TALLOC_ENV \
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
    touch "$STATE_DIR/talloc.installed"
}

build_talloc
