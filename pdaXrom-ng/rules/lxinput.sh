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

LXINPUT_VERSION=0.3.0
LXINPUT=lxinput-${LXINPUT_VERSION}.tar.gz
LXINPUT_MIRROR=http://downloads.sourceforge.net/project/lxde/LXInput%20%28Kbd%20and%20amp_%20mouse%20config%29/LXInput%200.3
LXINPUT_DIR=$BUILD_DIR/lxinput-${LXINPUT_VERSION}
LXINPUT_ENV="$CROSS_ENV_AC"

build_lxinput() {
    test -e "$STATE_DIR/lxinput.installed" && return
    banner "Build lxinput"
    download $LXINPUT_MIRROR $LXINPUT
    extract $LXINPUT
    apply_patches $LXINPUT_DIR $LXINPUT
    pushd $TOP_DIR
    cd $LXINPUT_DIR
    (
    eval \
	$CROSS_CONF_ENV \
	$LXINPUT_ENV \
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
    touch "$STATE_DIR/lxinput.installed"
}

build_lxinput
