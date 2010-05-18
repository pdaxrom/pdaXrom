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

FREETYPE=freetype-2.3.7.tar.bz2
FREETYPE_MIRROR=http://download.savannah.gnu.org/releases/freetype
FREETYPE_DIR=$BUILD_DIR/freetype-2.3.7
FREETYPE_ENV=

build_freetype() {
    test -e "$STATE_DIR/freetype-2.3.7" && return
    banner "Build $FREETYPE"
    download $FREETYPE_MIRROR $FREETYPE
    extract $FREETYPE
    apply_patches $FREETYPE_DIR $FREETYPE
    pushd $TOP_DIR
    cd $FREETYPE_DIR
    (
    eval \
	$CROSS_CONF_ENV \
	$FREETYPE_ENV \
	./configure --build=$BUILD_ARCH --host=$TARGET_ARCH \
	    --prefix=/usr \
	    --sysconfdir=/etc || error
    )
    make $MAKEARGS || error

    install_sysroot_files || error
    
    $INSTALL -D -m 644 objs/.libs/libfreetype.so.6.3.18 $ROOTFS_DIR/usr/lib/libfreetype.so.6.3.18 || error
    ln -sf libfreetype.so.6.3.18 $ROOTFS_DIR/usr/lib/libfreetype.so.6
    ln -sf libfreetype.so.6.3.18 $ROOTFS_DIR/usr/lib/libfreetype.so
    $STRIP $ROOTFS_DIR/usr/lib/libfreetype.so.6.3.18

    ln -sf $TARGET_BIN_DIR/bin/freetype-config $HOST_BIN_DIR/bin/

    popd
    touch "$STATE_DIR/freetype-2.3.7"
}

build_freetype
