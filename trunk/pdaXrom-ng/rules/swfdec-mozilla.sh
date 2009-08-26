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

#SWFDEC_MOZILLA_VERSION=0.9.2
SWFDEC_MOZILLA_VERSION=0.8.2
SWFDEC_MOZILLA=swfdec-mozilla-${SWFDEC_MOZILLA_VERSION}.tar.gz
SWFDEC_MOZILLA_MIRROR=http://swfdec.freedesktop.org/download/swfdec-mozilla/0.8
SWFDEC_MOZILLA_DIR=$BUILD_DIR/swfdec-mozilla-${SWFDEC_MOZILLA_VERSION}
SWFDEC_MOZILLA_ENV="$CROSS_ENV_AC"

build_swfdec_mozilla() {
    test -e "$STATE_DIR/swfdec_mozilla.installed" && return
    banner "Build swfdec-mozilla"
    download $SWFDEC_MOZILLA_MIRROR $SWFDEC_MOZILLA
    extract $SWFDEC_MOZILLA
    apply_patches $SWFDEC_MOZILLA_DIR $SWFDEC_MOZILLA
    pushd $TOP_DIR
    cd $SWFDEC_MOZILLA_DIR
    (
    eval \
	$CROSS_CONF_ENV \
	$SWFDEC_MOZILLA_ENV \
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
    touch "$STATE_DIR/swfdec_mozilla.installed"
}

build_swfdec_mozilla
