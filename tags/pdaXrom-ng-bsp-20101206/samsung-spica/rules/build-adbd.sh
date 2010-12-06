build_adbd() {
    test -e "$STATE_DIR/adbd.installed" && return

    rm -rf ${BUILD_DIR}/adb-extra
    cp -a ${BSP_SRC_DIR}/adb-extra $BUILD_DIR

    pushd $TOP_DIR
    cd ${BUILD_DIR}/adb-extra/adb

    make ${MAKEARGS} -f Makefile.adbd CC=${CROSS}gcc || error "build adbd"

    $STRIP adbd
    $INSTALL -D -m 755 adbd ${ROOTFS_DIR}/bin/adbd || error "install adbd"

    popd
    touch "$STATE_DIR/adbd.installed"
}

build_adbd
