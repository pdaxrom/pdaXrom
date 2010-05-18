#
# packet template
#
# Copyright (C) 2009 by Alexander Chukov <sash@pdaXrom.org>
#          
# See CREDITS for details about who has contributed to this project.
#
# For further information about the pdaXrom project and license conditions
# see the README file.
#

BLUEZ_UTILS3_VERSION=3.36
BLUEZ_UTILS3=bluez-utils-${BLUEZ_UTILS3_VERSION}.tar.gz
BLUEZ_UTILS3_MIRROR=http://bluez.sf.net/download
BLUEZ_UTILS3_DIR=$BUILD_DIR/bluez-utils-${BLUEZ_UTILS3_VERSION}
BLUEZ_UTILS3_ENV="$CROSS_ENV_AC"

if [ "$BLUEZ_UTILS3_BIN_FILES" = "" ]; then
    BLUEZ_UTILS3_BIN_FILES="hidd/hidd tools/hciconfig tools/hcitool"
fi

build_bluez_utils3() {
    test -e "$STATE_DIR/bluez_utils3.installed" && return
    banner "Build bluez-utils3"
    download $BLUEZ_UTILS3_MIRROR $BLUEZ_UTILS3
    extract $BLUEZ_UTILS3
    apply_patches $BLUEZ_UTILS3_DIR $BLUEZ_UTILS3
    pushd $TOP_DIR
    cd $BLUEZ_UTILS3_DIR
    (
    eval \
	$CROSS_CONF_ENV \
	$BLUEZ_UTILS3_ENV \
	./configure --build=$BUILD_ARCH --host=$TARGET_ARCH \
	    --prefix=/usr \
	    --sysconfdir=/etc \
	    --enable-hidd \
	    --disable-pie \
	    || error
    ) || error "configure"
    
    make -C common $MAKEARGS || error
    make -C tools $MAKEARGS || error
    make -C rfcomm $MAKEARGS || error
    make -C hidd $MAKEARGS || error

#    make $MAKEARGS || error

    mkdir -p $ROOTFS_DIR/usr/bin || error
    
    for f in $BLUEZ_UTILS3_BIN_FILES ; do
	$INSTALL -m 755 $f $ROOTFS_DIR/usr/bin/ || error
	$STRIP $ROOTFS_DIR/usr/bin/${f/*\/} || error
    done

    popd
    touch "$STATE_DIR/bluez_utils3.installed"
}

build_bluez_utils3
