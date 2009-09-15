create_lemote() {
    local T=`echo /tmp/lemote.$$`
    mkdir -p $T/boot

    if [ -e $IMAGES_DIR/uuid ]; then
	cp -f $GENERICFS_DIR/yeelong2f/boot.cfg.initrd $T/boot/boot.cfg
	test -f $IMAGES_DIR/initrd.img && cp -f $IMAGES_DIR/initrd.img $T/boot/
	cp -f $IMAGES_DIR/uuid       $T/boot/
    else
	cp -f $GENERICFS_DIR/yeelong2f/boot.cfg $T/boot/
    fi
    cp -f $IMAGES_DIR/rootfs.img $T/boot/
    cp -f $IMAGES_DIR/zImage     $T/boot/
    
    pushd $TOP_DIR
    cd $T

    local CDNAME="$ISOIMAGE_NAME"
    if [ "x$CDNAME" = "x" ]; then
	CDNAME="pdaXrom-ng-lemote"
    fi

    tar zcf ${IMAGES_DIR}/${CDNAME}-`date +%Y%m%d`.tgz .
    cd ${IMAGES_DIR}
    md5sum ${IMAGES_DIR}/${CDNAME}-`date +%Y%m%d`.tgz > ${IMAGES_DIR}/${CDNAME}-`date +%Y%m%d`.tgz.md5sum

    popd
}

create_lemote
