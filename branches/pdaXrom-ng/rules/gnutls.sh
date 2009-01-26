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

GNUTLS=gnutls-2.6.3.tar.bz2
GNUTLS_MIRROR=http://ftp.gnu.org/pub/gnu/gnutls
GNUTLS_DIR=$BUILD_DIR/gnutls-2.6.3
GNUTLS_ENV="$CROSS_ENV_AC"

build_gnutls() {
    test -e "$STATE_DIR/gnutls.installed" && return
    banner "Build gnutls"
    download $GNUTLS_MIRROR $GNUTLS
    extract $GNUTLS
    apply_patches $GNUTLS_DIR $GNUTLS
    pushd $TOP_DIR
    cd $GNUTLS_DIR
    (
    eval \
	$CROSS_CONF_ENV \
	$GNUTLS_ENV \
	./configure --build=$BUILD_ARCH --host=$TARGET_ARCH \
	    --prefix=/usr \
	    --sysconfdir=/etc \
	    --disable-gtk-doc \
	    --disable-guile \
	    --disable-nls
    ) || error "configure"

    sed -i -e 's:add_dir="-L$libdir"::g' libtool

    make $MAKEARGS || error

    install_sysroot_files || error
    
    ln -sf $TARGET_BIN_DIR/bin/libgnutls-config $HOST_BIN_DIR/bin/ || error
    
    $INSTALL -D -m 644 lib/.libs/libgnutls.so.26.11.4 $ROOTFS_DIR/usr/lib/libgnutls.so.26.11.4 || error
    ln -sf libgnutls.so.26.11.4 $ROOTFS_DIR/usr/lib/libgnutls.so.26
    ln -sf libgnutls.so.26.11.4 $ROOTFS_DIR/usr/lib/libgnutls.so
    $STRIP $ROOTFS_DIR/usr/lib/libgnutls.so.26.11.4

    popd
    touch "$STATE_DIR/gnutls.installed"
}

build_gnutls
