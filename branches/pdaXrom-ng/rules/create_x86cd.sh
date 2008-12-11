X86CD_TITLE="pdaXrom-ng x86 CD"

create_x86cd() {
    local T=`echo /tmp/x86cd.$$`
    mkdir -p $T/boot
    mkdir -p $T/isolinux
    cp -f $IMAGES_DIR/rootfs.img $T/boot/
    cp -f $IMAGES_DIR/bzImage    $T/boot/
    cp -f $HOST_BIN_DIR/share/syslinux/isolinux.bin $T/isolinux/
    printf "DEFAULT /boot/bzImage
APPEND  initrd=/boot/rootfs.img
LABEL live
  menu label ^Try Ubuntu without any change to your computer
  kernel /boot/bzImage
  append initrd=/boot/rootfs.img
DISPLAY isolinux.txt
TIMEOUT 300
PROMPT 1
" > $T/isolinux/isolinux.cfg
    printf "pdaXrom NG x86\n" > $T/isolinux/isolinux.txt
    
    pushd $TOP_DIR
    cd $T
    
    genisoimage -r -V "$X86CD_TITLE" -cache-inodes -J -l -o $IMAGES_DIR/pdaXrom-ng-x86.iso \
	-b isolinux/isolinux.bin -no-emul-boot -boot-load-size 4 -boot-info-table . \
	|| error "create x86 cd image"

    popd
}

create_x86cd
