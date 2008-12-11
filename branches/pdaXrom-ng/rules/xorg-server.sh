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

XORG_SERVER=xorg-server-1.5.3.tar.bz2
XORG_SERVER_MIRROR=ftp://ftp.freedesktop.org/pub/xorg/individual/xserver
XORG_SERVER_DIR=$BUILD_DIR/xorg-server-1.5.3
XORG_SERVER_ENV=
#"ac_cv_sys_linker_h=yes \
#	ac_cv_file__usr_share_sgml_X11_defs_ent=no \
#	ac_cv_asm_mtrr_h=no \
#	ac_cv_header_linux_agpgart_h=no"

build_xorg_server() {
    test -e "$STATE_DIR/xorg_server-1.4" && return
    banner "Build $XORG_SERVER"
    download $XORG_SERVER_MIRROR $XORG_SERVER
    extract $XORG_SERVER
    apply_patches $XORG_SERVER_DIR $XORG_SERVER
    pushd $TOP_DIR
    cd $XORG_SERVER_DIR
    (
    eval \
	$CROSS_CONF_ENV \
	$XORG_SERVER_ENV \
	./configure --host=$TARGET_ARCH \
	    --prefix=/usr \
	    --sysconfdir=/etc \
	    --localstatedir=/var \
	    --datadir=/usr/share \
	    --enable-shm \
	    --enable-freetype \
	    --disable-glx \
	    --disable-dri \
	    --enable-xorg \
	    --with-fontdir=/usr/share/fonts \
	    --without-dtrace \
	    || error
    )

    make $MAKEARGS || error

    install_sysroot_files || error
    
    make DESTDIR=$XORG_SERVER_DIR/fakeroot install || error
    
    cd $XORG_SERVER_DIR/fakeroot
    
    find ./usr/lib/xorg/modules -name "*.so" | while read f; do
	$INSTALL -D -m 644 $f $ROOTFS_DIR/$f || error "install modules"
	$STRIP $ROOTFS_DIR/$f
    done

    mkdir -p $ROOTFS_DIR/usr/share/X11/xkb/compiled || error

    $INSTALL -D -m 755 ./usr/bin/Xorg $ROOTFS_DIR/usr/bin/Xorg || error
    ln -sf Xorg $ROOTFS_DIR/usr/bin/X
    $STRIP $ROOTFS_DIR/usr/bin/Xorg

    popd
    touch "$STATE_DIR/xorg_server-1.4"
}

build_xorg_server
