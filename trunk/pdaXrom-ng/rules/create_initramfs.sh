INITRAMFS_DIR=$BUILD_DIR/initramfs

create_initramfs() {
    test -d $INITRAMFS_DIR || mkdir -p $INITRAMFS_DIR
    rm -rf $INITRAMFS_DIR/*
    local d=
    for d in bin boot dev mnt modules sys proc rootfs sbin; do
	mkdir -p $INITRAMFS_DIR/$d
    done

    local LIBDIR=lib
    if [ -e ${TOOLCHAIN_SYSROOT}/lib64 ]; then
	LIBDIR=lib64
    elif [ -e ${TOOLCHAIN_SYSROOT}/lib32 ]; then
	LIBDIR=lib32
    fi
    mkdir -p ${INITRAMFS_DIR}/lib
    if [ ! "$LIBDIR" = "lib" ]; then
	ln -sf lib ${INITRAMFS_DIR}/${LIBDIR}
    fi

    $INSTALL -D -m 755 $GENERICFS_DIR/init.initramfs $INITRAMFS_DIR/init || error

    pushd $TOP_DIR

    cp -a $ROOTFS_DIR/lib/ld-*.so $INITRAMFS_DIR/lib || error
    case $TARGET_ARCH in
    powerpc64*|ppc64*)
	cp -a $ROOTFS_DIR/lib/ld64.so* $INITRAMFS_DIR/lib || error
	;;
    *)
	cp -a $ROOTFS_DIR/lib/ld.so* $INITRAMFS_DIR/lib || error
	;;
    esac
    cp -a $ROOTFS_DIR/lib/libc-*.so $INITRAMFS_DIR/lib || error
    cp -a $ROOTFS_DIR/lib/libc.so* $INITRAMFS_DIR/lib || error
    cp -a $ROOTFS_DIR/lib/libm-*.so $INITRAMFS_DIR/lib || error
    cp -a $ROOTFS_DIR/lib/libm.so* $INITRAMFS_DIR/lib || error

    for f in bin/busybox bin/ash bin/sh bin/ls bin/cat bin/cp bin/dd bin/echo \
	    sbin/mkfs.minix bin/mount bin/umount bin/mkdir sbin/insmod \
	    sbin/init sbin/pivot_root sbin/rmmod bin/sleep bin/dmesg sbin/switch_root \
	    sbin/lsmod sbin/swapon sbin/swapoff sbin/mkswap sbin/losetup ; do
	cp -a $ROOTFS_DIR/$f $INITRAMFS_DIR/$f || error
    done

    ln -sf ../bin/busybox $INITRAMFS_DIR/sbin/chroot || error
    
    for f in [ test mknod tr cut cmp; do
	ln -sf ../bin/busybox $INITRAMFS_DIR/bin/$f || error
    done

    local MODULES="usb-storage.ko ohci-hcd.ko ehci-hcd.ko usbcore.ko sg.ko ps3vram.ko fat.ko vfat.ko isofs.ko udf.ko crc-itu-t.ko ps3vram.ko"

    for f in $MODULES; do
	find $ROOTFS_DIR/lib/modules -name $f -exec cp -R \{\} $INITRAMFS_DIR/modules \;
    done

    if [ "$USE_SPLASH" = "yes" ] && [ -f $ROOTFS_DIR/usr/bin/dancesplashfb ]; then
	cp -f $ROOTFS_DIR/usr/bin/dancesplashfb $INITRAMFS_DIR/bin || error "install dancesplashfb"
	mkdir -p $INITRAMFS_DIR/etc
	mkdir -p $INITRAMFS_DIR/usr/share
	cp -a $ROOTFS_DIR/usr/share/dancesplashfb $INITRAMFS_DIR/usr/share || error "install dancesplash share files"
	if [ -f $ROOTFS_DIR/etc/dancesplashfb.conf ]; then
	    cp -f $ROOTFS_DIR/etc/dancesplashfb.conf $INITRAMFS_DIR/etc
	    local IMG=`cat $ROOTFS_DIR/etc/dancesplashfb.conf | grep ^image | cut -d' ' -f2`
	    if [ -e $ROOTFS_DIR/$IMG ]; then
		echo "copy wallpaper $IMG"
		mkdir -p `dirname $INITRAMFS_DIR/$IMG` || error "mkdir wallpaper directory"
		cp -L $ROOTFS_DIR/$IMG $INITRAMFS_DIR/$IMG || error "install wallpaper"
	    fi
	fi
    fi

    uuidgen > $INITRAMFS_DIR/uuid
    cp -f $INITRAMFS_DIR/uuid $IMAGES_DIR/uuid

    cd $INITRAMFS_DIR
    
    find ./ | $CPIO -H newc -o | gzip -9 > $IMAGES_DIR/initrd.img

    popd
}

create_initramfs

copy_kernel_image
