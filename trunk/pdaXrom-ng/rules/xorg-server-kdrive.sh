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

XORG_SERVER_VERSION=1.9.2
XORG_SERVER=xorg-server-${XORG_SERVER_VERSION}.tar.bz2
XORG_SERVER_MIRROR=ftp://ftp.freedesktop.org/pub/xorg/individual/xserver
XORG_SERVER_DIR=$BUILD_DIR/xorg-server-${XORG_SERVER_VERSION}
XORG_SERVER_ENV=
#"ac_cv_sys_linker_h=yes \
#	ac_cv_file__usr_share_sgml_X11_defs_ent=no \
#	ac_cv_asm_mtrr_h=no \
#	ac_cv_header_linux_agpgart_h=no"

build_xorg_server_kdrive() {
    test -e "$STATE_DIR/xorg_server_kdrive-${XORG_SERVER_VERSION}" && return
    banner "Build $XORG_SERVER"
    download $XORG_SERVER_MIRROR $XORG_SERVER
    extract $XORG_SERVER
    apply_patches $XORG_SERVER_DIR $XORG_SERVER
    pushd $TOP_DIR
    cd $XORG_SERVER_DIR
    (
    if [ "$ENABLE_TSLIB" =  "yes" ]; then
        XORG_SERVER_TSLIB_CONF="--enable-tslib"
	XORG_SERVER_TSLIB_ENV="TSLIB_CFLAGS=$TARGET_BIN_DIR/include/ TSLIB_LIBS=$TARGET_BIN_DIR/lib/"
    fi
    eval \
	$CROSS_CONF_ENV \
	$XORG_SERVER_ENV \
	$XORG_SERVER_TSLIB_ENV \
	./configure --build=$BUILD_ARCH --host=$TARGET_ARCH \
	    --prefix=/usr \
	    --sysconfdir=/etc \
	    --localstatedir=/var \
	    --datadir=/usr/share \
	    --enable-shm \
	    --enable-freetype \
	    --disable-dri \
	    --disable-glx \
	    --disable-xorg \
	    --disable-dmx \
	    --disable-xvfb \
	    --disable-xnest \
	    --disable-kdrive \
	    --disable-xephyr \
	    --disable-xfake \
	    --enable-kdrive \
	    --enable-xfbdev \
	    --with-fontdir=/usr/share/fonts \
	    --without-dtrace \
	    $XORG_SERVER_TSLIB_CONF \
	    --with-xkb-output=/var/lib/xkb/compiled \
	    || error
    ) || error

    make $MAKEARGS || error

    install_sysroot_files || error

    install_fakeroot_init
    #ln -sf Xfbdev $ROOTFS_DIR/usr/bin/X
    install_fakeroot_finish || error

#
#
#    cp -f hw/xfree86/parser/xf86Optrec.h ${TARGET_INC}/xorg/ || error "workaround 1.6.2"
#    cp -f hw/xfree86/parser/xf86Parser.h ${TARGET_INC}/xorg/ || error "workaround 1.6.2"
#
#

    popd
    touch "$STATE_DIR/xorg_server_kdrive-${XORG_SERVER_VERSION}"
}

build_xorg_server_kdrive
