#
# packet template
#
# Copyright (C) 2009 by Adrian Crutchfield <insearchof@inventgen-solutions.com>
#
# See CREDITS for details about who has contributed to this project.
#
# For further information about the pdaXrom project and license conditions
# see the README file.
#

#TSLIB_VERSION=1.0
TSLIB_VERSION=07072006
TSLIB=tslib-${TSLIB_VERSION}.tar.bz2
#TSLIB_MIRROR=http://download.berlios.de/tslib
TSLIB_MIRROR=http://distro.ibiblio.org/pub/linux/distributions/pdaxrom/src/
TSLIB_DIR=$BUILD_DIR/tslib-${TSLIB_VERSION}
TSLIB_ENV="$CROSS_ENV_AC"

build_tslib() {
    test -e "$STATE_DIR/tslib.installed" && return
    banner "Build tslib"
    download $TSLIB_MIRROR $TSLIB
    extract $TSLIB
    apply_patches $TSLIB_DIR $TSLIB
    pushd $TOP_DIR
    cd $TSLIB_DIR
    (
case $TARGET_BUILD in
    spitz)
        TSLIB_ARGS="--disable-corgi --disable-collie --disable-h3600 --disable-mk712 --disable-arctic2 --disable-ucb1x00 --enable-input"
        ;;
    corgi)
        TSLIB_ARGS="--enable-corgi --disable-collie --disable-h3600 --disable-mk712 --disable-arctic2 --disable-ucb1x00 --disable-input"
        ;;
    collie)
        TSLIB_ARGS="--disable-corgi --enable-collie --disable-h3600 --disable-mk712 --disable-arctic2 --disable-ucb1x00 --disable-input"
        ;;
    *)
        ;;
    esac
	./autogen.sh
    eval \
	$CROSS_CONF_ENV \
	$TSLIB_ENV \
	./configure --build=$BUILD_ARCH --host=$TARGET_ARCH \
	    --prefix=/usr \
	    --sysconfdir=/etc \
	    $TARGET_BUILD \
	    || error
    ) || error "configure"

    make $MAKEARGS || error

    install_sysroot_files || error

    install_fakeroot_init

    install_fakeroot_finish || error

    popd
    touch "$STATE_DIR/tslib.installed"
}

build_tslib
