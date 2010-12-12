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

XFCE4_MIXER_VERSION=4.6.1
XFCE4_MIXER=xfce4-mixer-${XFCE4_MIXER_VERSION}.tar.bz2
XFCE4_MIXER_MIRROR=http://archive.xfce.org/src/apps/xfce4-mixer/4.6
XFCE4_MIXER_DIR=$BUILD_DIR/xfce4-mixer-${XFCE4_MIXER_VERSION}
XFCE4_MIXER_ENV="$CROSS_ENV_AC"

build_xfce4_mixer() {
    test -e "$STATE_DIR/xfce4_mixer.installed" && return
    banner "Build xfce4-mixer"
    download $XFCE4_MIXER_MIRROR $XFCE4_MIXER
    extract $XFCE4_MIXER
    apply_patches $XFCE4_MIXER_DIR $XFCE4_MIXER
    pushd $TOP_DIR
    cd $XFCE4_MIXER_DIR
    (
    eval \
	$CROSS_CONF_ENV \
	$XFCE4_MIXER_ENV \
	./configure --build=$BUILD_ARCH --host=$TARGET_ARCH \
	    --prefix=/usr \
	    --sysconfdir=/etc \
	    || error
    ) || error "configure"

    make $MAKEARGS || error

    #install_sysroot_files || error

    install_fakeroot_init

    install_fakeroot_finish || error

    popd
    touch "$STATE_DIR/xfce4_mixer.installed"
}

build_xfce4_mixer
