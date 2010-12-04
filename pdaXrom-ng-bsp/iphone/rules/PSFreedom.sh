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

PSFREEDOM_VERSION=
PSFREEDOM=PSFreedom${PSFREEDOM_VERSION}
PSFREEDOM_MIRROR=https://github.com/kakaroto/PSFreedom.git
PSFREEDOM_DIR=$BUILD_DIR/${PSFREEDOM}

PL3PAYLOAD_VERSION=
PL3PAYLOAD=PL3${PL3PAYLOAD_VERSION}
PL3PAYLOAD_MIRROR=https://github.com/kakaroto/PL3.git
PL3PAYLOAD_DIR=$BUILD_DIR/${PL3PAYLOAD}

PSFREEDOM_ENV="$CROSS_ENV_AC"

build_PSFreedom() {
    test -e "$STATE_DIR/PSFreedom.installed" && return
    banner "Build PSFreedom"
    download_git $PSFREEDOM_MIRROR $PSFREEDOM $PSFREEDOM_VERSION
    download_git $PL3PAYLOAD_MIRROR $PL3PAYLOAD $PL3PAYLOAD_VERSION
    extract $PSFREEDOM
    extract $PL3PAYLOAD
    apply_patches $PSFREEDOM_DIR $PSFREEDOM
    apply_patches $PL3PAYLOAD_DIR $PL3PAYLOAD
    pushd $TOP_DIR
    cd $PSFREEDOM_DIR
    rm -rf pl3
    ln -sf ../PL3 pl3

    local PPC_CROSS_PREFIX=/opt/powerpc-ps3-linux/toolchain/bin/powerpc-ps3-linux-
    local BUILD_ARGS="SUBARCH=`get_kernel_subarch $TARGET_ARCH` CROSS_COMPILE=${TOOLCHAIN_PREFIX}/bin/${CROSS} KDIR=$KERNEL_DIR PPU_CC=${PPC_CROSS_PREFIX}gcc PPU_OBJCOPY=${PPC_CROSS_PREFIX}objcopy"

    make iPhone $BUILD_ARGS $MAKEARGS || error

    $INSTALL -D -m 644 psfreedom.ko ${ROOTFS_DIR}/lib/modules/`ls ${ROOTFS_DIR}/lib/modules`/kernel/misc/psfreedom.ko
    local K_V=`ls $ROOTFS_DIR/lib/modules`
    $DEPMOD -a -b $ROOTFS_DIR $K_V

    popd
    touch "$STATE_DIR/PSFreedom.installed"
}

build_PSFreedom
