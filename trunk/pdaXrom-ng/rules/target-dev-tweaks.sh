target_dev_tweaks() {
    test -e $ROOTFS_DIR/usr/bin/groups || $INSTALL -D -m 755 $GENERICFS_DIR/groups $ROOTFS_DIR/usr/bin/groups || error "install groups"
    mkdir -p $ROOTFS_DIR/opt
}

target_dev_tweaks
