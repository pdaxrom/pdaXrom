DIRS="
bin
dev
etc
etc/init.d
home
lib
mnt
proc
root
sbin
sys
tmp
usr
usr/bin
usr/lib
usr/sbin
var
"

create_root() {
    test -e "$STATE_DIR/root_tree" && return
    
    local d=
    
    for d in $DIRS ; do
	mkdir -p "$ROOTFS_DIR/$d"
    done
    
    $INSTALL -m 755 $GENERICFS_DIR/etc/init.d/rcS $ROOTFS_DIR/etc/init.d/
    for f in $GENERICFS_DIR/etc/*; do
	test -f $f && $INSTALL -m 644 $f $ROOTFS_DIR/etc/
    done
    
    touch "$STATE_DIR/root_tree"
}

create_root
