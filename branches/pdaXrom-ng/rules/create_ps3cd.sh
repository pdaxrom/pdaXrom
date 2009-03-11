PS3CD_TITLE="pdaXrom-ng for Sony PS3"

create_ps3cd() {
    local T=`echo /tmp/ps3cd.$$`
    mkdir -p $T/boot
    mkdir -p $T/etc

    if [ -e $IMAGES_DIR/uuid ]; then
	cp -f $GENERICFS_DIR/kboot/kboot.conf.initramfs $T/etc/kboot.conf
	cp -f $IMAGES_DIR/initrd.img $T/boot/
	cp -f $IMAGES_DIR/uuid       $T/boot/
    else
	cp -f $GENERICFS_DIR/kboot/kboot.conf $T/etc/
    fi
    cp -f $GENERICFS_DIR/kboot/kboot.msg  $T/etc/
    cp -f $IMAGES_DIR/rootfs.img $T/boot/
    cp -f $IMAGES_DIR/zImage     $T/boot/
    
    pushd $TOP_DIR
    cd $T
    
    local CDNAME="$ISOIMAGE_NAME"
    if [ "x$CDNAME" = "x" ]; then
	CDNAME="pdaXrom-ng-ps3"
    fi
    
    genisoimage -r -V "$PS3CD_TITLE" -cache-inodes -J -l -o ${IMAGES_DIR}/${CDNAME}-`date +%Y%m%d`.iso . || error "create ps3 cd image"
    cd ${IMAGES_DIR}
    md5sum ${IMAGES_DIR}/${CDNAME}-`date +%Y%m%d`.iso > ${IMAGES_DIR}/${CDNAME}-`date +%Y%m%d`.iso.md5sum

    popd
}

create_ps3cd
