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

BMPANEL_VERSION=0.9.27
BMPANEL=bmpanel-${BMPANEL_VERSION}.tar.gz
BMPANEL_MIRROR=http://nsf.110mb.com/bmpanel
BMPANEL_DIR=$BUILD_DIR/bmpanel-${BMPANEL_VERSION}
BMPANEL_ENV="$CROSS_ENV_AC"

build_bmpanel() {
    test -e "$STATE_DIR/bmpanel.installed" && return
    banner "Build bmpanel"
    download $BMPANEL_MIRROR $BMPANEL
    extract $BMPANEL
    apply_patches $BMPANEL_DIR $BMPANEL
    pushd $TOP_DIR
    cd $BMPANEL_DIR
    CC=${CROSS}gcc ./configure --prefix=/usr --optimize || error

    make $MAKEARGS CC=${CROSS}gcc LD="${CROSS}gcc -Wl,-rpath,${TARGET_LIB}" DEBUG=1 || error

    #install_sysroot_files || error

    install_fakeroot_init

    install_fakeroot_finish || error

    popd
    touch "$STATE_DIR/bmpanel.installed"
}

build_bmpanel
