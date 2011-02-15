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

PCIUTILS=pciutils-3.0.3.tar.bz2
PCIUTILS_MIRROR=http://www.kernel.org/pub/software/utils/pciutils
PCIUTILS_DIR=$BUILD_DIR/pciutils-3.0.3
PCIUTILS_ENV="$CROSS_ENV_AC"

build_pciutils() {
    test -e "$STATE_DIR/pciutils.installed" && return
    banner "Build pciutils"
    download $PCIUTILS_MIRROR $PCIUTILS
    extract $PCIUTILS
    apply_patches $PCIUTILS_DIR $PCIUTILS
    pushd $TOP_DIR
    cd $PCIUTILS_DIR
#    (
#	cd lib
#	HOST=$TARGET_ARCH \
#	ZLIB=yes \
#	PREFIX=/usr \
#	./configure \
#	    || error
#    ) || error "configure"

    make $MAKEARGS HOST=$TARGET_ARCH ZLIB=no PREFIX=/usr  IDSDIR=/usr/share/hwdata \
	CC=${CROSS}gcc AR=${CROSS}ar RANLIB=${CROSS}ranlib || error

    $INSTALL -D -m 644 lib/libpci.a $TARGET_LIB/libpci.a || error
    $INSTALL -D -m 644 lib/config.h $TARGET_INC/pci/config.h || error
    $INSTALL -D -m 644 lib/header.h $TARGET_INC/pci/header.h || error
    $INSTALL -D -m 644 lib/pci.h    $TARGET_INC/pci/pci.h || error
    $INSTALL -D -m 644 lib/types.h  $TARGET_INC/pci/types.h || error

    $INSTALL -D -m 644 pci.ids $ROOTFS_DIR/usr/share/hwdata/pci.ids || error
    $INSTALL -D -m 755 lspci $ROOTFS_DIR/usr/sbin/lspci || error
    $STRIP $ROOTFS_DIR/usr/sbin/lspci
    $INSTALL -D -m 755 setpci $ROOTFS_DIR/usr/sbin/setpci || error
    $STRIP $ROOTFS_DIR/usr/sbin/setpci

    popd
    touch "$STATE_DIR/pciutils.installed"
}

build_pciutils
