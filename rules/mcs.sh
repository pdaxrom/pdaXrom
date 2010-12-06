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

MCS=libmcs-0.7.1.tgz
MCS_MIRROR=http://distfiles.atheme.org
MCS_DIR=$BUILD_DIR/libmcs-0.7.1
MCS_ENV="$CROSS_ENV_AC"

build_mcs() {
    test -e "$STATE_DIR/mcs.installed" && return
    banner "Build mcs"
    download $MCS_MIRROR $MCS
    extract $MCS
    apply_patches $MCS_DIR $MCS
    pushd $TOP_DIR
    cd $MCS_DIR
    (
    eval \
	$CROSS_CONF_ENV \
	$MCS_ENV \
	./configure --build=$BUILD_ARCH --host=$TARGET_ARCH \
	    --prefix=/usr \
	    --sysconfdir=/etc \
	    --disable-gconf \
	    --disable-kconfig \
	    --disable-examples \
	    || error
    ) || error "configure"
    
    make $MAKEARGS || error

    install_sysroot_files || error

    $INSTALL -D -m 644 src/libmcs/libmcs.so $ROOTFS_DIR/usr/lib/libmcs.so.1.0.0 || error
    ln -sf libmcs.so.1.0.0 $ROOTFS_DIR/usr/lib/libmcs.so.1
    ln -sf libmcs.so.1.0.0 $ROOTFS_DIR/usr/lib/libmcs.so
    $STRIP $ROOTFS_DIR/usr/lib/libmcs.so.1.0.0 || error
    
    $INSTALL -D -m 644 src/backends/default/keyfile.so $ROOTFS_DIR/usr/lib/mcs/keyfile.so || error
    $STRIP $ROOTFS_DIR/usr/lib/mcs/keyfile.so || error

    popd
    touch "$STATE_DIR/mcs.installed"
}

build_mcs
