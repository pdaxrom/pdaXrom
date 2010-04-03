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

LIBMMS_VERSION=0.4
LIBMMS=libmms-${LIBMMS_VERSION}.tar.gz
LIBMMS_MIRROR=http://code.launchpad.net/libmms/trunk/0.4/+download
LIBMMS_DIR=$BUILD_DIR/libmms-${LIBMMS_VERSION}
LIBMMS_ENV="$CROSS_ENV_AC"

build_libmms() {
    test -e "$STATE_DIR/libmms.installed" && return
    banner "Build libmms"
    download $LIBMMS_MIRROR $LIBMMS
    extract $LIBMMS
    apply_patches $LIBMMS_DIR $LIBMMS
    pushd $TOP_DIR
    cd $LIBMMS_DIR
    (
    eval \
	$CROSS_CONF_ENV \
	$LIBMMS_ENV \
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
    touch "$STATE_DIR/libmms.installed"
}

build_libmms
