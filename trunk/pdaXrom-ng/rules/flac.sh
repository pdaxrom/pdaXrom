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

FLAC_VERSION=1.2.1
FLAC=flac-${FLAC_VERSION}.tar.gz
FLAC_MIRROR=http://downloads.sourceforge.net/project/flac/flac-src/flac-1.2.1-src
FLAC_DIR=$BUILD_DIR/flac-${FLAC_VERSION}
FLAC_ENV="$CROSS_ENV_AC"

build_flac() {
    test -e "$STATE_DIR/flac.installed" && return
    banner "Build flac"
    download $FLAC_MIRROR $FLAC
    extract $FLAC
    apply_patches $FLAC_DIR $FLAC
    pushd $TOP_DIR
    cd $FLAC_DIR
    (
    eval \
	$CROSS_CONF_ENV \
	$FLAC_ENV \
	./configure --build=$BUILD_ARCH --host=$TARGET_ARCH \
	    --prefix=/usr \
	    --sysconfdir=/etc \
	    --with-ogg=$TARGET_BIN_DIR \
	    --disable-xmms-plugin \
	    --disable-cpplibs \
	    || error
    ) || error "configure"

    make $MAKEARGS || error

    install_sysroot_files || error

    install_fakeroot_init || error
    install_fakeroot_finish || error

    popd
    touch "$STATE_DIR/flac.installed"
}

build_flac
