X86CD_TITLE=${CDROM_TITLE-"pdaXrom-ng x86 CD"}

create_x86cd() {
    local T=`echo /tmp/x86cd.$$`
    mkdir -p $T/boot
    mkdir -p $T/isolinux
    cp -f $IMAGES_DIR/rootfs.img $T/boot/
    cp -f $IMAGES_DIR/bzImage    $T/boot/
    cp -f $HOST_BIN_DIR/share/syslinux/isolinux.bin $T/isolinux/

    if [ "$USE_INITRAMFS" = "yes" ]; then
	if [ "$USE_SPLASH" = "yes" ]; then
	    cp -f $GENERICFS_DIR/isolinux/initramfs/isolinux.cfg.splash $T/isolinux/isolinux.cfg
	else
	    cp -f $GENERICFS_DIR/isolinux/initramfs/isolinux.cfg $T/isolinux/isolinux.cfg
	fi
	cp -f $IMAGES_DIR/uuid       $T/boot/
    else
	if [ "$USE_SPLASH" = "yes" ]; then
	    cp -f $GENERICFS_DIR/isolinux/isolinux.cfg.splash $T/isolinux/isolinux.cfg
	else
	    cp -f $GENERICFS_DIR/isolinux/isolinux.cfg $T/isolinux/isolinux.cfg
	fi
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
