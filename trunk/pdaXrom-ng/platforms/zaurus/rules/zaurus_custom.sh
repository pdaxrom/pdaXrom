create_customizations() {
    
    $INSTALL -m 755 $BSP_GENERICFS_DIR/etc/init.d/zaurushw $ROOTFS_DIR/etc/init.d/ || error
    install_rc_start zaurushw 99

    for f in $BSP_GENERICFS_DIR/etc/*; do
	test -f $f && $INSTALL -m 644 $f $ROOTFS_DIR/etc/
    done

    mkdir -p $ROOTFS_DIR/usr/share/keymaps/
    cp $BSP_GENERICFS_DIR/keymaps/spitz.keymap $ROOTFS_DIR/usr/share/keymaps/

    touch "$STATE_DIR/zaurus_customizations"
}

create_customizations
