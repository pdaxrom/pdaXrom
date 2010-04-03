DIRS="
bin
boot
dev
etc
etc/default
etc/init.d
etc/rc.d
etc/network
etc/network/if-down.d
etc/network/if-post-down.d
etc/network/if-pre-up.d
etc/network/if-up.d
etc/profile.d
home/root
media
mnt
proc
root
sbin
sys
tmp
usr
usr/bin
usr/sbin
var
var/lock
var/lock/subsys
var/log
var/lib
var/run
var/tmp
"

create_root() {
    test -e "$STATE_DIR/root_tree" && return
    
    local d=
    
    for d in $DIRS ; do
	mkdir -p "$ROOTFS_DIR/$d"
    done
    
    $INSTALL -m 755 $GENERICFS_DIR/etc/init.d/rcS $ROOTFS_DIR/etc/init.d/ || error
    $INSTALL -m 755 $GENERICFS_DIR/etc/init.d/rcK $ROOTFS_DIR/etc/init.d/ || error
    $INSTALL -m 644 $GENERICFS_DIR/etc/init.d/functions $ROOTFS_DIR/etc/init.d/ || error
    $INSTALL -m 755 $GENERICFS_DIR/etc/init.d/sysklogd $ROOTFS_DIR/etc/init.d/ || error
    $INSTALL -m 755 $GENERICFS_DIR/etc/init.d/network $ROOTFS_DIR/etc/init.d/ || error
    install_rc_start sysklogd 05
    install_rc_stop  sysklogd 75
    install_rc_start network 40
    install_rc_stop  network 60

    for f in $GENERICFS_DIR/etc/*; do
	test -f $f && $INSTALL -m 644 $f $ROOTFS_DIR/etc/
    done

    mkdir -p ${ROOTFS_DIR}/lib
    mkdir -p ${ROOTFS_DIR}/usr/lib
    case $TARGET_ARCH in
    powerpc64-*|ppc64-*|x86_64-*|amd64-*|mips64*-*)
	local LIBDIR=lib
	if [ -e ${TOOLCHAIN_SYSROOT}/lib64 ]; then
	    LIBDIR=lib64
	elif [ -e ${TOOLCHAIN_SYSROOT}/lib32 ]; then
	    LIBDIR=lib32
	fi
	if [ ! "$LIBDIR" = "lib" ]; then
	    ln -sf lib ${ROOTFS_DIR}/${LIBDIR}
	    ln -sf lib ${ROOTFS_DIR}/usr/${LIBDIR}
	fi
	;;
    esac

    $INSTALL -m 644 $GENERICFS_DIR/etc/network/interfaces $ROOTFS_DIR/etc/network/

    chmod 777 $ROOTFS_DIR/tmp $ROOTFS_DIR/var/tmp

    touch "$STATE_DIR/root_tree"
}

create_root
