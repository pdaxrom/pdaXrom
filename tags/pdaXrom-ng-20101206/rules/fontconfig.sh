#
# packet template
#
# Copyright (C) 2008 by Alexander Chukov <sash@pdaXrom.org>
#          
# See CREDITS for details about who has contributed to this project.
#
# For further information about the pdaXrom project and license conditions
# see the README file.
#

FONTCONFIG_VERSION=2.8.0
FONTCONFIG=fontconfig-${FONTCONFIG_VERSION}.tar.gz
FONTCONFIG_MIRROR=http://fontconfig.org/release
FONTCONFIG_DIR=$BUILD_DIR/fontconfig-${FONTCONFIG_VERSION}
FONTCONFIG_ENV=

build_fontconfig() {
    test -e "$STATE_DIR/fontconfig-${FONTCONFIG_VERSION}" && return
    banner "Build $FONTCONFIG"
    download $FONTCONFIG_MIRROR $FONTCONFIG
    extract $FONTCONFIG
    apply_patches $FONTCONFIG_DIR $FONTCONFIG
    pushd $TOP_DIR
    cd $FONTCONFIG_DIR
    (
    eval \
	$CROSS_CONF_ENV \
	$FONTCONFIG_ENV \
	./configure --build=$BUILD_ARCH --host=$TARGET_ARCH \
	    --prefix=/usr \
	    --sysconfdir=/etc \
	    --disable-docs \
	    --with-cache-dir=/var/cache/fontconfig \
	    --with-default-fonts=/usr/share/fonts \
	    --with-arch=$TARGET_ARCH \
	    || error
    )
    make $MAKEARGS || error

    install_sysroot_files || error

    install_fakeroot_init
    install_fakeroot_finish || error

    #$INSTALL -D -m 644 fonts.conf $ROOTFS_DIR/etc/fonts/fonts.conf || error

    popd
    touch "$STATE_DIR/fontconfig-${FONTCONFIG_VERSION}"
}

build_fontconfig
