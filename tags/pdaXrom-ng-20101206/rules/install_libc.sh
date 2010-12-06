case $TARGET_ARCH in
*uclibc*)
LIBC_LIBS="
libcrypt
libnsl
libpthread
libresolv
librt
libutil
"

LIBC_SYS_LIBS="
ld
libc
libuClibc
libm
libdl
"
    ;;
*)
LIBC_LIBS="
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

LIBC_SYS_LIBS="
ld
libc
libm
libdl
"
LIBC_GCONV_MODULES="
$LIBC_GCONV_MODULES
UNICODE.so
"
    ;;
esac

install_libc() {
    test -e "$STATE_DIR/install_libc" && return

    case $TARGET_ARCH in
    powerpc64-*|ppc64-*)
	LIBC_SYS_LIBS="ld64 $LIBC_SYS_LIBS"
	;;    
    esac

    local lib=
    local f=
    for lib in $LIBC_SYS_LIBS $LIBC_LIBS; do
	echo "Library: $lib"
	ls ${TOOLCHAIN_LIBC_DIR}/${lib}[.-]* | while read f; do
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

    if [ -d $TOOLCHAIN_SYSROOT/usr/lib/gconv ]; then
	$INSTALL -D -m 644 $TOOLCHAIN_SYSROOT/usr/lib/gconv/gconv-modules $ROOTFS_DIR/usr/lib/gconv/gconv-modules || error
        for f in ISO8859-1.so $LIBC_GCONV_MODULES; do
	    echo "Installing $f"
	    $INSTALL -D -m 644 $TOOLCHAIN_SYSROOT/usr/lib/gconv/$f $ROOTFS_DIR/usr/lib/gconv/$f || error
	    $STRIP $ROOTFS_DIR/usr/lib/gconv/$f
	done
    fi
    
    touch "$STATE_DIR/install_libc"
}

install_libc
