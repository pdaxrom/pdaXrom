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

TIFF_VERSION=3.9.4
TIFF=tiff-${TIFF_VERSION}.tar.gz
TIFF_MIRROR=ftp://ftp.remotesensing.org/pub/libtiff
TIFF_DIR=$BUILD_DIR/tiff-${TIFF_VERSION}
TIFF_ENV="$CROSS_ENV_AC"

build_tiff() {
    test -e "$STATE_DIR/tiff.installed" && return
    banner "Build tiff"
    download $TIFF_MIRROR $TIFF
    extract $TIFF
    apply_patches $TIFF_DIR $TIFF
    pushd $TOP_DIR
    cd $TIFF_DIR
    (
    eval \
	$CROSS_CONF_ENV \
	$TIFF_ENV \
	./configure --build=$BUILD_ARCH --host=$TARGET_ARCH \
	    --prefix=/usr \
	    --sysconfdir=/etc \
	    || error
    ) || error "configure"
    sed -i -e 's:add_dir="-L$libdir"::g' libtool
    make $MAKEARGS || error

    install_sysroot_files || error

    install_fakeroot_init

    rm -rf fakeroot/usr/bin

    install_fakeroot_finish || error

    popd
    touch "$STATE_DIR/tiff.installed"
}

build_tiff
