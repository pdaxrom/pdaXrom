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

XFCE4_SESSION_VERSION=4.7.2
XFCE4_SESSION=xfce4-session-${XFCE4_SESSION_VERSION}.tar.bz2
XFCE4_SESSION_MIRROR=http://archive.xfce.org/src/xfce/xfce4-session/4.7
XFCE4_SESSION_DIR=$BUILD_DIR/xfce4-session-${XFCE4_SESSION_VERSION}
XFCE4_SESSION_ENV="$CROSS_ENV_AC"

build_xfce4_session() {
    test -e "$STATE_DIR/xfce4_session.installed" && return
    banner "Build xfce4-session"
    download $XFCE4_SESSION_MIRROR $XFCE4_SESSION
    extract $XFCE4_SESSION
    apply_patches $XFCE4_SESSION_DIR $XFCE4_SESSION
    pushd $TOP_DIR
    cd $XFCE4_SESSION_DIR
    (
    eval \
	$CROSS_CONF_ENV \
	$XFCE4_SESSION_ENV \
	./configure --build=$BUILD_ARCH --host=$TARGET_ARCH \
	    --prefix=/usr \
	    --sysconfdir=/etc \
	    || error
    ) || error "configure"

    make $MAKEARGS || error

    install_sysroot_files || error

    install_fakeroot_init

    install_fakeroot_finish || error

    popd
    touch "$STATE_DIR/xfce4_session.installed"
}

build_xfce4_session
