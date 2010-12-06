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

POPPLER_DATA_VERSION=0.4.3
POPPLER_DATA=poppler-data-${POPPLER_DATA_VERSION}.tar.gz
POPPLER_DATA_MIRROR=http://poppler.freedesktop.org
POPPLER_DATA_DIR=$BUILD_DIR/poppler-data-${POPPLER_DATA_VERSION}
POPPLER_DATA_ENV="$CROSS_ENV_AC"

build_poppler_data() {
    test -e "$STATE_DIR/poppler_data.installed" && return
    banner "Build poppler-data"
    download $POPPLER_DATA_MIRROR $POPPLER_DATA
    extract $POPPLER_DATA
    apply_patches $POPPLER_DATA_DIR $POPPLER_DATA
    pushd $TOP_DIR
    cd $POPPLER_DATA_DIR

    install_fakeroot_init prefix=/usr
    install_fakeroot_finish || error

    popd
    touch "$STATE_DIR/poppler_data.installed"
}

build_poppler_data
