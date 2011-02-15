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

POPPLER_VERSION=0.14.3
POPPLER=poppler-${POPPLER_VERSION}.tar.gz
POPPLER_MIRROR=http://poppler.freedesktop.org
POPPLER_DIR=$BUILD_DIR/poppler-${POPPLER_VERSION}
POPPLER_ENV="$CROSS_ENV_AC"

build_poppler() {
    test -e "$STATE_DIR/poppler.installed" && return
    banner "Build poppler"
    download $POPPLER_MIRROR $POPPLER
    extract $POPPLER
    apply_patches $POPPLER_DIR $POPPLER
    pushd $TOP_DIR
    cd $POPPLER_DIR
    (
    eval \
	$CROSS_CONF_ENV \
	$POPPLER_ENV \
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
    touch "$STATE_DIR/poppler.installed"
}

build_poppler
