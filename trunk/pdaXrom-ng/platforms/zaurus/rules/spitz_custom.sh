create_customizations() {
    
    $INSTALL -m 755 $BSP_GENERICFS_DIR/etc/init.d/zaurushw $ROOTFS_DIR/etc/init.d/ || error
    install_rc_start zaurushw 98

    for f in $BSP_GENERICFS_DIR/etc/*; do
	test -f $f && $INSTALL -m 644 $f $ROOTFS_DIR/etc/
    done

    mkdir -p $ROOTFS_DIR/usr/share/keymaps/
    $INSTALL -m 644 $BSP_GENERICFS_DIR/keymaps/spitz.keymap $ROOTFS_DIR/usr/share/keymaps/ || error
    $INSTALL -m 644 $BSP_GENERICFS_DIR/configs/xorg.conf $ROOTFS_DIR/etc/X11/xorg.conf 
    $INSTALL -m 644 $BSP_GENERICFS_DIR/configs/ts.conf_spitz $ROOTFS_DIR/etc/ts.conf 
    $INSTALL -m 755 $BSP_GENERICFS_DIR/scripts/startx_spitz $ROOTFS_DIR/usr/bin/startx

    touch "$STATE_DIR/zaurus_customizations"
}

create_customizations
