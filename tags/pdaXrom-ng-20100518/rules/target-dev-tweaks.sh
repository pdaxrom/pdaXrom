target_dev_tweaks() {
    test -e $ROOTFS_DIR/usr/bin/groups || $INSTALL -D -m 755 $GENERICFS_DIR/groups $ROOTFS_DIR/usr/bin/groups || error "install groups"
    test -f $TOOLCHAIN_SYSROOT/usr/bin/rpcgen && install_rootfs_usr_bin $TOOLCHAIN_SYSROOT/usr/bin/rpcgen
    test -f $TOOLCHAIN_SYSROOT/usr/bin/ldd && $INSTALL -D -m 755 $TOOLCHAIN_SYSROOT/usr/bin/ldd $ROOTFS_DIR/usr/bin/ldd
    test -f $TOOLCHAIN_SYSROOT/sbin/ldconfig && $INSTALL -D -m 755 $TOOLCHAIN_SYSROOT/sbin/ldconfig $ROOTFS_DIR/sbin/ldconfig && $STRIP $ROOTFS_DIR/sbin/ldconfig
    ln -sf ../usr/bin/cpp $ROOTFS_DIR/lib/cpp
    mkdir -p $ROOTFS_DIR/opt

    tar c -C $TARGET_INC . | tar x -C ${ROOTFS_DIR}/usr/include || error "includes"
    cp -a ${TARGET_LIB}/pkgconfig ${ROOTFS_DIR}/usr/lib || error "pkgconfig dir"

    pushd $PWD
    cd $TARGET_LIB
    find . -name "*.h" -exec install -D -m 644 {} ${ROOTFS_DIR}/usr/lib/{} \;
    popd

    cp -a ${TARGET_BIN_DIR}/bin/*-config ${ROOTFS_DIR}/usr/bin || error "dev config files"

    sed -i -e "s|${TARGET_BIN_DIR}||" ${ROOTFS_DIR}/usr/lib/pkgconfig/*.pc

    test -f ${TARGET_LIB}/libSDLmain.a && cp -a ${TARGET_LIB}/libSDLmain.a ${ROOTFS_DIR}/usr/lib/

    find ${ROOTFS_DIR}/usr/bin/ -name "*-config" | while read f; do
	file $f | grep -q "POSIX shell script" && sed -i -e "s|${TARGET_BIN_DIR}||" $f
    done

    # fix old X11 inc/lib search path
    test -e $ROOTFS_DIR/usr/X11R6 || ln -sf . $ROOTFS_DIR/usr/X11R6
}

target_dev_tweaks
