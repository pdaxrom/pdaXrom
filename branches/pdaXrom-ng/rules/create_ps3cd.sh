PS3CD_TITLE="pdaXrom-ng for Sony PS3"

create_ps3cd_squashfs() {
    rm -f $IMAGES_DIR/rootfs.img
    mksquashfs $ROOTFS_DIR $IMAGES_DIR/rootfs.img -be -all-root || error
}

create_ps3cd() {
    local T=`echo /tmp/ps3cd.$$`
    mkdir -p $T/boot
    mkdir -p $T/etc
    cp -f $GENERICFS_DIR/kboot/kboot.conf $T/etc/
    cp -f $GENERICFS_DIR/kboot/kboot.msg  $T/etc/
    cp -f $IMAGES_DIR/rootfs.img $T/boot/
    cp -f $IMAGES_DIR/zImage     $T/boot/
    
    pushd $TOP_DIR
    cd $T
    
    genisoimage -r -V "$PS3CD_TITLE" -cache-inodes -J -l -o $IMAGES_DIR/pdaXrom-ng-ps3.iso . || error "create ps3 cd image"

    popd
}

#create_ps3cd_squashfs
create_ps3cd
