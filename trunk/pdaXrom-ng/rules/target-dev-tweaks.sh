target_dev_tweaks() {
    test -e $ROOTFS_DIR/usr/bin/groups || $INSTALL -D -m 755 $GENERICFS_DIR/groups $ROOTFS_DIR/usr/bin/groups || error "install groups"
    test -f $TOOLCHAIN_SYSROOT/usr/bin/rpcgen && install_rootfs_usr_bin $TOOLCHAIN_SYSROOT/usr/bin/rpcgen
    ln -sf ../usr/bin/cpp $ROOTFS_DIR/lib/cpp
    mkdir -p $ROOTFS_DIR/opt
}

target_dev_tweaks
