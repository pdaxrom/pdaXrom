X86FAT_TITLE=${FAT_TITLE-"pdaXrom-ng"}

create_x86bootfat() {
    local T=`echo /tmp/x86bootfat.$$`
    mkdir -p $T/boot
    cp -f $IMAGES_DIR/rootfs.img $T/boot/
    cp -f $IMAGES_DIR/bzImage    $T/

    if [ "$USE_INITRAMFS" = "yes" ]; then
	if [ "$USE_SPLASH" = "yes" ]; then
	    cp -f $GENERICFS_DIR/isolinux/initramfs/syslinux.cfg.splash $T/syslinux.cfg
	else
	    cp -f $GENERICFS_DIR/isolinux/initramfs/syslinux.cfg $T/syslinux.cfg
	fi
	cp -f $IMAGES_DIR/uuid       $T/boot/
    else
	if [ "$USE_SPLASH" = "yes" ]; then
	    cp -f $GENERICFS_DIR/isolinux/syslinux.cfg.splash $T/syslinux.cfg
	else
	    cp -f $GENERICFS_DIR/isolinux/syslinux.cfg $T/syslinux.cfg
	fi
    fi

    printf "${X86CD_TITLE-pdaXrom NG x86}\n" > $T/syslinux.txt

    pushd $TOP_DIR

    local FATNAME="$FATIMAGE_NAME"
    if [ "x$FATNAME" = "x" ]; then
	FATNAME="pdaXrom-ng"
    fi

    local OUT_FILE="${IMAGES_DIR}/${FATNAME}-`date +%Y%m%d`.img"

    dd if=/dev/zero of=$T/boot/writable.img bs=1M count=64 || error "Can't create writable.img file image!"
    mkfs.ext3 -F $T/boot/writable.img

    local IMG_SIZE=`du -sh $T | awk '{ sub(/M$/,"",$1); print $1+2 }'`
    for f in $BOOTFAT_IMAGE_SIZE 60 120 250 500 1000 2000 4000 8000 16000 32000; do
	if [ $IMG_SIZE -le $f ]; then
	    IMG_SIZE=$f
	    break
	fi
    done
    IMG_SIZE=$((IMG_SIZE * 1000 / 1024 - 1))
    dd if=/dev/zero of=${OUT_FILE} bs=1M count=${IMG_SIZE} || error "Can't create empty image file!"

    makebootfat -v -o ${OUT_FILE} -Y \
	-b ${HOST_SYSLINUX_DIR}/core/ldlinux.bss \
	-m ${HOST_SYSLINUX_DIR}/mbr/mbr.bin \
	-O ${X86FAT_TITLE} -L ${X86FAT_TITLE} \
	-c ${HOST_SYSLINUX_DIR}/core/ldlinux.sys \
	$T || error create x86 bootable fat image

    cd ${IMAGES_DIR}
    md5sum ${IMAGES_DIR}/${FATNAME}-`date +%Y%m%d`.img > ${OUT_FILE}.md5sum

    popd
}

create_x86bootfat
