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

FONTCONFIG=fontconfig-2.6.0.tar.gz
FONTCONFIG_MIRROR=http://fontconfig.org/release
FONTCONFIG_DIR=$BUILD_DIR/fontconfig-2.6.0
FONTCONFIG_ENV=

build_fontconfig() {
    test -e "$STATE_DIR/fontconfig-2.6.0" && return
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
	./configure --host=$TARGET_ARCH \
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

    $INSTALL -D -m 644 src/.libs/libfontconfig.so.1.3.0 $ROOTFS_DIR/usr/lib/libfontconfig.so.1.3.0 || error
    ln -sf libfontconfig.so.1.3.0 $ROOTFS_DIR/usr/lib/libfontconfig.so.1
    ln -sf libfontconfig.so.1.3.0 $ROOTFS_DIR/usr/lib/libfontconfig.so
    $STRIP $ROOTFS_DIR/usr/lib/libfontconfig.so.1.3.0

    popd
    touch "$STATE_DIR/fontconfig-2.6.0"
}

build_fontconfig
