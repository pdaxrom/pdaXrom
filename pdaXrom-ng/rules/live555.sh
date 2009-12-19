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

LIVE555_VERSION=2009.11.27
LIVE555=live.${LIVE555_VERSION}.tar.gz
LIVE555_MIRROR=http://www.live555.com/liveMedia/public
LIVE555_DIR=$BUILD_DIR/live
LIVE555_ENV="$CROSS_ENV_AC"

build_live555() {
    test -e "$STATE_DIR/live555.installed" && return
    banner "Build live555"
    download $LIVE555_MIRROR $LIVE555
    extract $LIVE555
    apply_patches $LIVE555_DIR $LIVE555
    pushd $TOP_DIR
    cd $LIVE555_DIR

    ./genMakefiles linux

    make \
	C_COMPILER=${CROSS}gcc \
	CPLUSPLUS_COMPILER=${CROSS}g++ \
	LINK="${CROSS}g++ -o" \
	LIBRARY_LINK="${CROSS}ar cr "

    install_sysroot_files \
	C_COMPILER=${CROSS}gcc \
	CPLUSPLUS_COMPILER=${CROSS}g++ \
	LINK="${CROSS}g++ -o" \
	LIBRARY_LINK="${CROSS}ar cr" \
	|| error

    install_fakeroot_init

    error "update install"

    install_fakeroot_finish || error

    popd
    touch "$STATE_DIR/live555.installed"
}

build_live555
