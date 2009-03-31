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

XKEYBOARD_CONFIG_VERSION=1.4
XKEYBOARD_CONFIG=xkeyboard-config-${XKEYBOARD_CONFIG_VERSION}.tar.bz2
XKEYBOARD_CONFIG_MIRROR=ftp://ftp.freedesktop.org/pub/xorg/individual/data
XKEYBOARD_CONFIG_DIR=$BUILD_DIR/xkeyboard-config-${XKEYBOARD_CONFIG_VERSION}
XKEYBOARD_CONFIG_ENV="$CROSS_ENV_AC"

build_xkeyboard_config() {
    test -e "$STATE_DIR/xkeyboard_config.installed" && return
    banner "Build xkeyboard-config"
    download $XKEYBOARD_CONFIG_MIRROR $XKEYBOARD_CONFIG
    extract $XKEYBOARD_CONFIG
    apply_patches $XKEYBOARD_CONFIG_DIR $XKEYBOARD_CONFIG
    pushd $TOP_DIR
    cd $XKEYBOARD_CONFIG_DIR
    (
    eval \
	$CROSS_CONF_ENV \
	$XKEYBOARD_CONFIG_ENV \
	./configure --build=$BUILD_ARCH --host=$TARGET_ARCH \
	    --prefix=/usr \
	    --sysconfdir=/etc \
	    --datadir=/usr/share \
	    || error
    ) || error "configure"
    
    make $MAKEARGS || error

    make $MAKEARGS DESTDIR=$ROOTFS_DIR install itlocaledir=/../target/share/locale || error

    ln -sf base $ROOTFS_DIR/usr/share/X11/xkb/rules/xorg
    ln -sf base.lst $ROOTFS_DIR/usr/share/X11/xkb/rules/xorg.lst
    ln -sf base.xml $ROOTFS_DIR/usr/share/X11/xkb/rules/xorg.xml

    ln -sf base $ROOTFS_DIR/usr/share/X11/xkb/rules/xfree86
    ln -sf base.lst $ROOTFS_DIR/usr/share/X11/xkb/rules/xfree86.lst
    ln -sf base.xml $ROOTFS_DIR/usr/share/X11/xkb/rules/xfree86.xml

    popd
    touch "$STATE_DIR/xkeyboard_config.installed"
}

build_xkeyboard_config
