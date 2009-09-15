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

QEMU_VERSION=0.11.0-rc1
QEMU=qemu-${QEMU_VERSION}.tar.gz
QEMU_MIRROR=http://download.savannah.gnu.org/releases/qemu
QEMU_DIR=$BUILD_DIR/qemu-${QEMU_VERSION}
QEMU_ENV="$CROSS_ENV_AC"

build_qemu() {
    test -e "$STATE_DIR/qemu.installed" && return
    banner "Build qemu"
    download $QEMU_MIRROR $QEMU
    extract $QEMU
    apply_patches $QEMU_DIR $QEMU
    pushd $TOP_DIR
    cd $QEMU_DIR
    (
    eval \
	$CROSS_CONF_ENV \
	$QEMU_ENV \
	./configure \
	    --prefix=/usr \
	    --cross-prefix=$CROSS \
	    --cc=gcc \
	    --host-cc=gcc \
	    --audio-drv-list=alsa,sdl \
	    --disable-linux-user \
	    --disable-darwin-user \
	    --disable-bsd-user \
	    --extra-cflags="-L$TARGET_LIB" \
	    --extra-ldflags="-L$TARGET_LIB" \
	    --disable-kqemu \
	    --disable-kvm \
	    --target-list=i386-softmmu \
	    --interp-prefix=/usr/lib/gnemul/qemu-%M \
	    --disable-strip \
	    || error
    ) || error "configure"
    
    make $MAKEARGS || error

    make $MAKEARGS DESTDIR=$ROOTFS_DIR install || error
    
    $STRIP $ROOTFS_DIR/usr/bin/qemu*

    popd
    touch "$STATE_DIR/qemu.installed"
}

build_qemu
