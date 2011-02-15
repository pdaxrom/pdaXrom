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

TARGET_PKGCONFIG_VERSION=0.23
TARGET_PKGCONFIG=pkg-config-${TARGET_PKGCONFIG_VERSION}.tar.gz
TARGET_PKGCONFIG_MIRROR=http://pkgconfig.freedesktop.org/releases
TARGET_PKGCONFIG_DIR=$BUILD_DIR/pkg-config-${TARGET_PKGCONFIG_VERSION}
TARGET_PKGCONFIG_ENV="$CROSS_ENV_AC"

build_target_pkgconfig() {
    test -e "$STATE_DIR/target_pkgconfig.installed" && return
    banner "Build target_pkgconfig"
    download $TARGET_PKGCONFIG_MIRROR $TARGET_PKGCONFIG
    extract $TARGET_PKGCONFIG
    apply_patches $TARGET_PKGCONFIG_DIR $TARGET_PKGCONFIG
    pushd $TOP_DIR
    cd $TARGET_PKGCONFIG_DIR
    (
    eval \
	$CROSS_CONF_ENV \
	$TARGET_PKGCONFIG_ENV \
	./configure --build=$BUILD_ARCH --host=$TARGET_ARCH \
	    --prefix=/usr \
	    --sysconfdir=/etc \
	    --with-installed-glib \
	    || error
    ) || error "configure"

    make $MAKEARGS || error

    install_fakeroot_init
    install_fakeroot_finish || error

    popd
    touch "$STATE_DIR/target_pkgconfig.installed"
}

build_target_pkgconfig
