build_su() {
    test -e "$STATE_DIR/su.installed" && return

    rm -rf ${BUILD_DIR}/su
    cp -a ${BSP_SRC_DIR}/su $BUILD_DIR

    pushd $TOP_DIR
    cd ${BUILD_DIR}/su

    make ${MAKEARGS} -f Makefile.su CC=${CROSS}gcc || error "build su"

    $STRIP su
    $INSTALL -D -m 4755 su ${ROOTFS_DIR}/bin/su || error "install su"

    popd
    touch "$STATE_DIR/su.installed"
}

build_su
