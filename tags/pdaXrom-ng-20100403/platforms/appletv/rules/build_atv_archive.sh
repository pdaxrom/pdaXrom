#!/bin/sh

build_atv_archive() {
    rm -rf ${BUILD_DIR}/bootpart
    cp -a ${BSP_SRC_DIR}/bootpart ${BUILD_DIR}/bootpart
    cp -f ${IMAGES_DIR}/mach_kernel ${BUILD_DIR}/bootpart
    pushd $TOP_DIR
    find ${BUILD_DIR}/bootpart -name ".svn" -type d | xargs rm -rf
    cd ${BUILD_DIR}/bootpart
    tar czf ${IMAGES_DIR}/${ISOIMAGE_NAME}-`date +%Y%m%d`.tar.gz .
    ln -sf ${ISOIMAGE_NAME}-`date +%Y%m%d`.tar.gz ${IMAGES_DIR}/LATEST.tar.gz
    popd
}

build_atv_archive
