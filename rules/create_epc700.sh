create_epc700() {
    local T=`echo /tmp/epc700.$$`
    mkdir -p $T/boot

    if [ -e $IMAGES_DIR/uuid ]; then
	cp -f $IMAGES_DIR/uuid       $T/boot/
    fi
    cp -f $IMAGES_DIR/rootfs.img $T/boot/
    cp -f $IMAGES_DIR/${TARGET_KERNEL_IMAGE-vmlinuz} $T/
    
    pushd $TOP_DIR
    cd $T

    local CDNAME="$ISOIMAGE_NAME"
    if [ "x$CDNAME" = "x" ]; then
	CDNAME="pdaXrom-ng-epc700"
    fi

    zip -r9 ${IMAGES_DIR}/${CDNAME}-`date +%Y%m%d`.zip .
    cd ${IMAGES_DIR}
    md5sum ${IMAGES_DIR}/${CDNAME}-`date +%Y%m%d`.zip > ${IMAGES_DIR}/${CDNAME}-`date +%Y%m%d`.zip.md5sum

    popd
}

create_epc700
