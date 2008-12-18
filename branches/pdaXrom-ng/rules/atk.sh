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

ATK=atk-1.25.2.tar.bz2
ATK_MIRROR=http://ftp.acc.umu.se/pub/gnome/sources/atk/1.25
ATK_DIR=$BUILD_DIR/atk-1.25.2
ATK_ENV="$CROSS_ENV_AC"

build_atk() {
    test -e "$STATE_DIR/atk.installed" && return
    banner "Build atk"
    download $ATK_MIRROR $ATK
    extract $ATK
    apply_patches $ATK_DIR $ATK
    pushd $TOP_DIR
    cd $ATK_DIR
    (
    eval \
	$CROSS_CONF_ENV \
	$ATK_ENV \
	./configure --host=$TARGET_ARCH \
	    --prefix=/usr \
	    --sysconfdir=/etc \
	    --x-includes=$TARGET_INC \
	    --x-libraries=$TARGET_LIB \
	    || error
    ) || error "configure"
    
    make $MAKEARGS || error

    install_sysroot_files || error
    
    $INSTALL -D -m 644 atk/.libs/libatk-1.0.so.0.2511.1 $ROOTFS_DIR/usr/lib/libatk-1.0.so.0.2511.1 || error
    ln -sf libatk-1.0.so.0.2511.1 $ROOTFS_DIR/usr/lib/libatk-1.0.so.0
    ln -sf libatk-1.0.so.0.2511.1 $ROOTFS_DIR/usr/lib/libatk-1.0.so
    $STRIP $ROOTFS_DIR/usr/lib/libatk-1.0.so.0.2511.1

    popd
    touch "$STATE_DIR/atk.installed"
}

build_atk
