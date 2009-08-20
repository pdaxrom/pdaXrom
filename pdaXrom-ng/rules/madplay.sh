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

MADPLAY_VERSION=0.15.2b
MADPLAY=madplay-${MADPLAY_VERSION}.tar.gz
MADPLAY_MIRROR=ftp://ftp.mars.org/pub/mpeg
MADPLAY_DIR=$BUILD_DIR/madplay-${MADPLAY_VERSION}
MADPLAY_ENV="$CROSS_ENV_AC"

build_madplay() {
    test -e "$STATE_DIR/madplay.installed" && return
    banner "Build madplay"
    download $MADPLAY_MIRROR $MADPLAY
    extract $MADPLAY
    apply_patches $MADPLAY_DIR $MADPLAY
    pushd $TOP_DIR
    cd $MADPLAY_DIR
    (
    eval \
	$CROSS_CONF_ENV \
	$MADPLAY_ENV \
	./configure --build=$BUILD_ARCH --host=$TARGET_ARCH \
	    --prefix=/usr \
	    --sysconfdir=/etc \
	    --with-alsa \
	    || error
    ) || error "configure"

    make $MAKEARGS || error

    #install_sysroot_files || error

    install_fakeroot_init || error
    install_fakeroot_finish || error

    popd
    touch "$STATE_DIR/madplay.installed"
}

build_madplay
