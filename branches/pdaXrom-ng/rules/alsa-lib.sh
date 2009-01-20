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

ALSA_LIB=alsa-lib-1.0.19.tar.bz2
ALSA_LIB_MIRROR=ftp://ftp.alsa-project.org/pub/lib
ALSA_LIB_DIR=$BUILD_DIR/alsa-lib-1.0.19
ALSA_LIB_ENV=

build_alsa_lib() {
    test -e "$STATE_DIR/alsa_lib-1.0.18" && return
    banner "Build $ALSA_LIB"
    download $ALSA_LIB_MIRROR $ALSA_LIB
    extract $ALSA_LIB
    apply_patches $ALSA_LIB_DIR $ALSA_LIB
    pushd $TOP_DIR
    cd $ALSA_LIB_DIR
    (
    eval \
	$CROSS_CONF_ENV \
	$ALSA_LIB_ENV \
	./configure --build=$BUILD_ARCH --host=$TARGET_ARCH \
	    --prefix=/usr \
	    --sysconfdir=/etc \
	    --disable-python || error
    )
    make $MAKEARGS || error

    install_sysroot_files

    $STRIP src/.libs/libasound.so.2.0.0 modules/mixer/simple/.libs/*.so
    
    $INSTALL -m 644 src/.libs/libasound.so.2.0.0 $ROOTFS_DIR/usr/lib/
    ln -sf libasound.so.2.0.0 $ROOTFS_DIR/usr/lib/libasound.so.2
    ln -sf libasound.so.2.0.0 $ROOTFS_DIR/usr/lib/libasound.so
    mkdir -p $ROOTFS_DIR/usr/lib/alsa-lib/smixer
    for f in modules/mixer/simple/.libs/*.so; do
	$INSTALL -m 644 $f $ROOTFS_DIR/usr/lib/alsa-lib/smixer/
    done
    
    # copy alsa configs as is
    cp -R $TARGET_BIN_DIR/usr/share/alsa $ROOTFS_DIR/usr/share

    popd
    touch "$STATE_DIR/alsa_lib-1.0.18"
}

build_alsa_lib
