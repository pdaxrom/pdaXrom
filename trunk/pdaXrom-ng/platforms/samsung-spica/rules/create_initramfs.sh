INITRAMFS_DIR=$BUILD_DIR/initramfs

create_initramfs() {
    rm -rf $INITRAMFS_DIR
    test -d $INITRAMFS_DIR || mkdir -p $INITRAMFS_DIR

    local SUBARCH=`get_kernel_subarch $TARGET_ARCH`

    pushd $TOP_DIR

    cd $BUILD_DIR
    cd $INITRAMFS_DIR
    tar jxf ${BSP_GENERICFS_DIR}/initramfs.tar.bz2 || error "unpack initramfs"

    cp -a ${ROOTFS_DIR}/lib/modules/`ls ${ROOTFS_DIR}/lib/modules`/extra/* ${INITRAMFS_DIR}/lib/modules/

    $INSTALL -D -m 4755 ${ROOTFS_DIR}/bin/busybox ${INITRAMFS_DIR}/sbin/busybox

    ln -sf busybox ${INITRAMFS_DIR}/sbin/ash
    ln -sf busybox ${INITRAMFS_DIR}/sbin/su
    ln -sf busybox ${INITRAMFS_DIR}/sbin/chroot
    ln -sf busybox ${INITRAMFS_DIR}/sbin/switch_root

cat > ${INITRAMFS_DIR}/default.prop << EOF
#
# ADDITIONAL_DEFAULT_PROPERTIES
#
ro.secure=0
ro.debuggable=1
persist.service.adb.enable=1
EOF

    echo "root::0:0:root:/:/sbin/ash" > ${INITRAMFS_DIR}/sbin/passwd.txt

    #$INSTALL -D -m 644 ${BSP_GENERICFS_DIR}/init.rc ${INITRAMFS_DIR}/init.rc
    $INSTALL -D -m 755 ${BSP_GENERICFS_DIR}/passwd_inst.sh ${INITRAMFS_DIR}/sbin/passwd_inst.sh

    cd $KERNEL_DIR
    bash scripts/gen_initramfs_list.sh $INITRAMFS_DIR > $BUILD_DIR/initramfs.list
    sed -i -e "s/`id -u` `id -g`$/0 0/" $BUILD_DIR/initramfs.list

    make SUBARCH=$SUBARCH CROSS_COMPILE=${TOOLCHAIN_PREFIX}/bin/${CROSS} $MAKEARGS `get_kernel_image $TARGET_ARCH` CONFIG_INITRAMFS_SOURCE=$BUILD_DIR/initramfs.list || error

    popd
}

create_initramfs

copy_kernel_image
