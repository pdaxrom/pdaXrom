PS3CD_TITLE="pdaXrom-ng for Sony PS3"

PS3_OTHEROS_PATH="../ps3-ps3boot-distro/images"

create_ps3cd() {
    local T=`echo /tmp/ps3cd.$$`
    mkdir -p $T/boot
    mkdir -p $T/etc

    if [ -e $IMAGES_DIR/uuid ]; then
	if [ "$USE_SPLASH" = "yes" ]; then
	    cp -f $GENERICFS_DIR/kboot/kboot.conf.initramfs.splash $T/etc/kboot.conf
	else
	    cp -f $GENERICFS_DIR/kboot/kboot.conf.initramfs $T/etc/kboot.conf
	fi
	test -f $IMAGES_DIR/initrd.img && cp -f $IMAGES_DIR/initrd.img $T/boot/
	cp -f $IMAGES_DIR/uuid       $T/boot/
    else
	if [ "$USE_SPLASH" = "yes" ]; then
	    cp -f $GENERICFS_DIR/kboot/kboot.conf.splash $T/etc/kboot.conf
	else
	    cp -f $GENERICFS_DIR/kboot/kboot.conf $T/etc/
	fi
    fi
    cp -f $GENERICFS_DIR/kboot/kboot.msg  $T/etc/
    cp -f $IMAGES_DIR/rootfs.img $T/boot/
    cp -f $IMAGES_DIR/zImage     $T/boot/

    if test -e ${PS3_OTHEROS_PATH}/*.bld ; then
	mkdir -p $T/PS3/otheros
	cp -f ${PS3_OTHEROS_PATH}/*.bld $T/PS3/otheros/otheros.bld
    fi

    pushd $TOP_DIR
    cd $T

    local CDNAME="$ISOIMAGE_NAME"
    if [ "x$CDNAME" = "x" ]; then
	CDNAME="pdaXrom-ng-ps3"
    fi

    genisoimage -r -V "$PS3CD_TITLE" -cache-inodes -J -l -o ${IMAGES_DIR}/${CDNAME}-`date +%Y%m%d`.iso . || error "create ps3 cd image"
    zip -r9 ${IMAGES_DIR}/${CDNAME}-`date +%Y%m%d`.zip .
    cd ${IMAGES_DIR}
    md5sum ${IMAGES_DIR}/${CDNAME}-`date +%Y%m%d`.iso > ${IMAGES_DIR}/${CDNAME}-`date +%Y%m%d`.iso.md5sum
    md5sum ${IMAGES_DIR}/${CDNAME}-`date +%Y%m%d`.zip > ${IMAGES_DIR}/${CDNAME}-`date +%Y%m%d`.zip.md5sum

    popd
}

create_ps3cd
