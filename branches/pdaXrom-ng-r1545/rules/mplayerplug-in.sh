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

MPLAYERPLUG_IN_VERSION=3.55
MPLAYERPLUG_IN=mplayerplug-in-${MPLAYERPLUG_IN_VERSION}.tar.gz
MPLAYERPLUG_IN_MIRROR=http://prdownloads.sourceforge.net/mplayerplug-in
MPLAYERPLUG_IN_DIR=$BUILD_DIR/mplayerplug-in-${MPLAYERPLUG_IN_VERSION}
MPLAYERPLUG_IN_ENV="$CROSS_ENV_AC GECKO_XPIDL=$FIREFOX_DIR/dist/host/bin/host_xpidl GECKO_IDLDIR=$FIREFOX_DIR/dist/idl"

build_mplayerplug_in() {
    test -e "$STATE_DIR/mplayerplug_in.installed" && return
    banner "Build mplayerplug-in"
    download $MPLAYERPLUG_IN_MIRROR $MPLAYERPLUG_IN
    extract $MPLAYERPLUG_IN
    apply_patches $MPLAYERPLUG_IN_DIR $MPLAYERPLUG_IN
    pushd $TOP_DIR
    cd $MPLAYERPLUG_IN_DIR
    (
    eval \
	$CROSS_CONF_ENV \
	$MPLAYERPLUG_IN_ENV \
	./configure --build=$BUILD_ARCH --host=$TARGET_ARCH \
	    --prefix=/usr \
	    --sysconfdir=/etc \
	    --with-gecko-sdk=$FIREFOX_DIR/dist/sdk \
	    || error
    ) || error "configure"

    make $MAKEARGS || error

    #install_sysroot_files || error

    install_fakeroot_init
    install_fakeroot_finish || error

    popd
    touch "$STATE_DIR/mplayerplug_in.installed"
}

build_mplayerplug_in
