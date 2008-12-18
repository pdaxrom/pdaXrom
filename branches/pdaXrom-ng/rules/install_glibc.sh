GLIBC_LIBS="
libcrypt
libnsl
libnss_compat
libnss_dns
libnss_files
libnss_hesiod
libnss_nis
libnss_nisplus
libpthread
libresolv
librt
libthread_db
libutil
"

GLIBC_SYS_LIBS="
ld
libc
libm
libdl
"

install_glibc() {
    test -e "$STATE_DIR/install_glibc" && return
    mkdir -p $ROOTFS_DIR/lib
    mkdir -p $ROOTFS_DIR/usr/lib
    local lib=
    local f=
    for lib in $GLIBC_SYS_LIBS $GLIBC_LIBS; do
	echo "Library: $lib"
	ls ${GLIBC_DIR}/${lib}[.-]* | while read f; do
	    echo "Installing ${f/*\//}"
	    cp -R $f $ROOTFS_DIR/lib || error
	    $STRIP $ROOTFS_DIR/lib/${f/*\//}
	done
    done
    
    for f in libgcc_s.so libstdc++.so ; do
	local L=`${TARGET_ARCH}-gcc -print-file-name=$f`
	L=`readlink $L`
	L=`${TARGET_ARCH}-gcc -print-file-name=${L/*\//}`
	local ff=
	find `dirname $L` -name "$f*" | while read ff; do
	    if [ "$L" = "$ff" ]; then
		$INSTALL -m 644 $ff $ROOTFS_DIR/usr/lib/ || error "install $ff"
		$STRIP $ROOTFS_DIR/usr/lib/${ff/*\//}
	    else
		ln -sf ${L/*\//} $ROOTFS_DIR/usr/lib/${ff/*\//}
	    fi
	done
	#$INSTALL -m 644 $L $ROOTFS_DIR/usr/lib/
	#ln -sf ${L/*\//} $ROOTFS_DIR/usr/lib/$f
	#$STRIP $ROOTFS_DIR/usr/lib/${L/*\//}
    done
        
    touch "$STATE_DIR/install_glibc"
}

install_glibc
