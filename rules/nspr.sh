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

NSPR_VERSION=4.8.2
NSPR=nspr-${NSPR_VERSION}.tar.gz
NSPR_MIRROR=https://ftp.mozilla.org/pub/mozilla.org/nspr/releases/v4.8.2/src
NSPR_DIR=$BUILD_DIR/nspr-${NSPR_VERSION}
NSPR_ENV="$CROSS_ENV_AC"

build_nspr() {
    test -e "$STATE_DIR/nspr.installed" && return
    banner "Build nspr"
    download $NSPR_MIRROR $NSPR
    extract $NSPR
    apply_patches $NSPR_DIR $NSPR
    pushd $TOP_DIR
    cd $NSPR_DIR/mozilla/nsprpub
    (
    eval \
	$CROSS_CONF_ENV \
	$NSPR_ENV \
	./configure --build=$BUILD_ARCH --target=$TARGET_ARCH \
	    --prefix=/usr \
	    --sysconfdir=/etc \
	    || error
    ) || error "configure"

    make $MAKEARGS || error

    install_sysroot_files || error

    ln -sf ${TARGET_BIN_DIR}/bin/nspr-config ${HOST_BIN_DIR}/bin/nspr-config

    install_fakeroot_init
    rm -rf fakeroot/usr/bin fakeroot/usr/share
    install_fakeroot_finish || error

    popd
    touch "$STATE_DIR/nspr.installed"
}

build_nspr
