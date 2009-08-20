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

LIBMTP_VERSION=0.3.7
LIBMTP=libmtp-${LIBMTP_VERSION}.tar.gz
LIBMTP_MIRROR=http://downloads.sourceforge.net/libmtp/libmtp-0.3.7.tar.gz
LIBMTP_DIR=$BUILD_DIR/libmtp-${LIBMTP_VERSION}
LIBMTP_ENV="$CROSS_ENV_AC"

build_libmtp() {
    test -e "$STATE_DIR/libmtp.installed" && return
    banner "Build libmtp"
    download $LIBMTP_MIRROR $LIBMTP
    extract $LIBMTP
    apply_patches $LIBMTP_DIR $LIBMTP
    pushd $TOP_DIR
    cd $LIBMTP_DIR
    (
    eval \
	$CROSS_CONF_ENV \
	$LIBMTP_ENV \
	./configure --build=$BUILD_ARCH --host=$TARGET_ARCH \
	    --prefix=/usr \
	    --sysconfdir=/etc \
	    || error
    ) || error "configure"

    make $MAKEARGS || error

    install_sysroot_files || error

    install_fakeroot_init || error
    install_fakeroot_finish || error

    popd
    touch "$STATE_DIR/libmtp.installed"
}

build_libmtp
