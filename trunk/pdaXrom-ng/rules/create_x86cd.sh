X86CD_TITLE=${CDROM_TITLE-"pdaXrom-ng x86 CD"}

create_x86cd() {
    local T=`echo /tmp/x86cd.$$`
    mkdir -p $T/boot
    mkdir -p $T/isolinux
    cp -f $IMAGES_DIR/rootfs.img $T/boot/
    cp -f $IMAGES_DIR/bzImage    $T/boot/
    cp -f $HOST_BIN_DIR/share/syslinux/isolinux.bin $T/isolinux/

    if [ "$USE_SPLASH" = "yes" ]; then
    printf "DEFAULT /boot/bzImage
APPEND  initrd=/boot/rootfs.img root=/dev/ram0 ramdisk_size=128000 vga=0x314 console=/dev/tty2 quiet splash
LABEL live
  menu label ^Try pdaXrom in vesa mode
  kernel /boot/bzImage
  append initrd=/boot/rootfs.img root=/dev/ram0 ramdisk_size=128000 vga=0x314 console=/dev/tty2 quiet splash
LABEL safe
  menu label ^Try pdaXrom in text mode
  kernel /boot/bzImage
  append initrd=/boot/rootfs.img root=/dev/ram0 ramdisk_size=128000
DISPLAY isolinux.txt
TIMEOUT 50
PROMPT 1
" > $T/isolinux/isolinux.cfg
    else
    printf "DEFAULT /boot/bzImage
APPEND  initrd=/boot/rootfs.img root=/dev/ram0 ramdisk_size=128000 vga=0x314 quiet
LABEL live
  menu label ^Try pdaXrom in vesa mode
  kernel /boot/bzImage
  append initrd=/boot/rootfs.img root=/dev/ram0 ramdisk_size=128000 vga=0x314 quiet
LABEL safe
  menu label ^Try pdaXrom in text mode
  kernel /boot/bzImage
  append initrd=/boot/rootfs.img root=/dev/ram0 ramdisk_size=128000
DISPLAY isolinux.txt
TIMEOUT 50
PROMPT 1
" > $T/isolinux/isolinux.cfg
    fi
    printf "pdaXrom NG x86\n" > $T/isolinux/isolinux.txt
    
    pushd $TOP_DIR
    cd $T

    local CDNAME="$ISOIMAGE_NAME"
    if [ "x$CDNAME" = "x" ]; then
	CDNAME="pdaXrom-ng-x86"
    fi

    local OUT_FILE="${IMAGES_DIR}/${CDNAME}-`date +%Y%m%d`.iso"

    genisoimage -r -V "$X86CD_TITLE" -cache-inodes -J -l -o ${OUT_FILE} \
	-b isolinux/isolinux.bin -no-emul-boot -boot-load-size 4 -boot-info-table . \
	|| error "create x86 cd image"

    isohybrid ${OUT_FILE}

    cd ${IMAGES_DIR}
    md5sum ${IMAGES_DIR}/${CDNAME}-`date +%Y%m%d`.iso > ${OUT_FILE}.md5sum

    popd
}

create_x86cd
