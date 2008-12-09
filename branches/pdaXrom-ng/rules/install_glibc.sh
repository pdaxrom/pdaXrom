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
    local lib=
    local f=
    for lib in $GLIBC_SYS_LIBS $GLIBC_LIBS; do
	echo "Library: $lib"
	find $GLIBC_DIR -name $lib\* | while read f; do
	    echo "Installing ${f/*\//}"
	    cp -R $f $ROOTFS_DIR/lib || error
	done
    done
    touch "$STATE_DIR/install_glibc"
}

install_glibc
