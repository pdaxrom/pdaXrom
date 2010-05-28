#
# packet template
#
# Copyright (C) 2009 by Adrian Crutchfield <insearchof@inventgen-solutioons.com
#
# See CREDITS for details about who has contributed to this project.
#
# For further information about the pdaXrom project and license conditions
# see the README file.
#

BAREBOX_VERSION=2010.05.0
BAREBOX=barebox-${BAREBOX_VERSION}.tar.bz2
BAREBOX_MIRROR=http://www.barebox.org/download
BAREBOX_DIR=$BUILD_DIR/barebox-${BAREBOX_VERSION}
BAREBOX_ENV="$CROSS_ENV_AC"

if [ "x$BAREBOX_CONFIG" = "x" ]; then
    error "No barebox config defined!"
fi

build_barebox() {
    test -e "$STATE_DIR/barebox.installed" && return
    banner "Build barebox"
    download $BAREBOX_MIRROR $BAREBOX
    extract $BAREBOX
    apply_patches $BAREBOX_DIR $BAREBOX
    pushd $TOP_DIR
    cd $BAREBOX_DIR

#    make ${BAREBOX_CONFIG}_defconfig || error "configure barebox"
    make $MAKEARGS || error

    #install_sysroot_files || error

    install_fakeroot_init

    error "update install"

    install_fakeroot_finish || error

    popd
    touch "$STATE_DIR/barebox.installed"
}

build_barebox
