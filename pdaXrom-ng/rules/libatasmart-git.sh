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

LIBATASMART_GIT_VERSION=e7bb10a7df894c8d14c62958f859e62b6c7fb9fb
LIBATASMART_GIT=libatasmart-${LIBATASMART_GIT_VERSION}
LIBATASMART_GIT_URL=git://git.0pointer.de/libatasmart.git
LIBATASMART_GIT_DIR=$BUILD_DIR/libatasmart-${LIBATASMART_GIT_VERSION}
LIBATASMART_GIT_ENV="$CROSS_ENV_AC"

build_libatasmart_git() {
    test -e "$STATE_DIR/libatasmart_git.installed" && return
    banner "Build libatasmart"
    download_git $LIBATASMART_GIT_URL $LIBATASMART_GIT $LIBATASMART_GIT_VERSION
    cp -R $SRC_DIR/$LIBATASMART_GIT $LIBATASMART_GIT_DIR
    apply_patches $LIBATASMART_GIT_DIR $LIBATASMART_GIT
    pushd $TOP_DIR
    cd $LIBATASMART_GIT_DIR
    ./bootstrap.sh || error "bootstraping"
    (
    eval \
	$CROSS_CONF_ENV \
	$LIBATASMART_GIT_ENV \
	./configure --build=$BUILD_ARCH --host=$TARGET_ARCH \
	    --prefix=/usr \
	    --sysconfdir=/etc \
	    || error
    ) || error "configure"

    make strpool CC=gcc || error
    make $MAKEARGS || error

    install_sysroot_files || error

    install_fakeroot_init

    rm -rf fakeroot/usr/share/vala

    install_fakeroot_finish || error

    popd
    touch "$STATE_DIR/libatasmart_git.installed"
}

build_libatasmart_git
