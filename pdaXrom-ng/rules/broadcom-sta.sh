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

BROADCOM_STA_VERSION=5.10.91.9
BROADCOM_STA=bcmwl-${BROADCOM_STA_VERSION}.tar.bz2
BROADCOM_STA_MIRROR=http://mail.pdaXrom.org/downloads/src
BROADCOM_STA_DIR=$BUILD_DIR/bcmwl-${BROADCOM_STA_VERSION}
BROADCOM_STA_ENV="$CROSS_ENV_AC"

build_broadcom_sta() {
    test -e "$STATE_DIR/broadcom_sta.installed" && return
    banner "Build broadcom-sta"
    download $BROADCOM_STA_MIRROR $BROADCOM_STA
    extract $BROADCOM_STA
    apply_patches $BROADCOM_STA_DIR $BROADCOM_STA
    pushd $TOP_DIR
    cd $BROADCOM_STA_DIR
    case $TARGET_ARCH in
    i*86*)
	ln -sf wlc_hybrid.o_shipped_i386 lib/wlc_hybrid.o_shipped
	;;
    x86_64*|amd64*)
	ln -sf wlc_hybrid.o_shipped_x86_64 lib/wlc_hybrid.o_shipped
	;;
    *)
	error "x86 arch only"
	;;
    esac

    local SUBARCH=`get_kernel_subarch $TARGET_ARCH`

    make $MAKEARGS KERNEL_SRC=$KERNEL_DIR SUBARCH=$SUBARCH CROSS_COMPILE=${TOOLCHAIN_PREFIX}/bin/${CROSS}  || error
    make KERNEL_MODULES=${ROOTFS_DIR}/lib/modules/`ls ${ROOTFS_DIR}/lib/modules` install || error

    local K_V=`ls $ROOTFS_DIR/lib/modules`
    $DEPMOD -a -b $ROOTFS_DIR $K_V

    sleep 5

    popd
    touch "$STATE_DIR/broadcom_sta.installed"
}

build_broadcom_sta
