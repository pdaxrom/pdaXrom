SPICA_MODULES=" \
	MODULES_DPRAM=y \
	MODULES_CAMERA=y \
	MODULES_WLAN=y \
	MODULES_MULTIMEDIA=y \
	MODULES_VIBETONZ=y \
	MODULES_BTGPIO=y \
	MODULES_PARAM=y \
"

build_spica_mods() {
    test -e "$STATE_DIR/modules.installed" && return

    cp -a $BSP_SRC_DIR/modules $BUILD_DIR

    pushd $TOP_DIR

    cd $BUILD_DIR/modules

    local SUBARCH=`get_kernel_subarch $TARGET_ARCH`

    mkdir -p "${ROOTFS_DIR}/lib/modules/`ls ${ROOTFS_DIR}/lib/modules`/extra/"
    cp -f ${BSP_SRC_DIR}/modules-proprietary/*.ko ${ROOTFS_DIR}/lib/modules/`ls ${ROOTFS_DIR}/lib/modules`/extra/

    make SUBARCH=$SUBARCH CROSS_COMPILE=${TOOLCHAIN_PREFIX}/bin/${CROSS} $MAKEARGSz KDIR=${KERNEL_DIR} PRJROOT=${BUILD_DIR} \
	${SPICA_MODULES} \
	|| error

    make SUBARCH=$SUBARCH CROSS_COMPILE=${TOOLCHAIN_PREFIX}/bin/${CROSS} $MAKEARGSz KDIR=${KERNEL_DIR} PRJROOT=${BUILD_DIR} \
	${SPICA_MODULES} \
	install \
	INSTALL_MOD_PATH=$ROOTFS_DIR \
	|| error

    popd
    touch "$STATE_DIR/modules.installed"
}

build_spica_mods
