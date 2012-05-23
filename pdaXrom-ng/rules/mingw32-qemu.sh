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

MINGW32_QEMU=qemu-0.9.1.tar.gz
MINGW32_QEMU_MIRROR=http://wiki.qemu.org/download
MINGW32_QEMU_DIR=$BUILD_DIR/qemu-0.9.1
MINGW32_QEMU_ENV="$CROSS_ENV_AC"

build_mingw32_qemu() {
    test -e "$STATE_DIR/mingw32_qemu.installed" && return
    banner "Build mingw32-qemu"
    download $MINGW32_QEMU_MIRROR $MINGW32_QEMU
    extract $MINGW32_QEMU
    apply_patches $MINGW32_QEMU_DIR $MINGW32_QEMU
    pushd $TOP_DIR
    cd $MINGW32_QEMU_DIR
    (
    eval \
	$CROSS_CONF_ENV \
	$MINGW32_QEMU_ENV \
	targetos=CYGWIN cpu=i386 ./configure --cross-prefix=${TARGET_ARCH}- \
	    --disable-vnc-tls \
	    --host-cc=gcc \
	    --disable-linux-user \
	    --disable-darwin-user \
	    --target-list=i386-softmmu,x86_64-softmmu,arm-softmmu,ppc-softmmu,ppcemb-softmmu,ppc64-softmmu \
	    || error
    ) || error "configure"
    
    make $MAKEARGS BASE_LDFLAGS="-mno-cygwin" || error

    find . -name "qemu*.exe" | while read f; do
	$STRIP $f
	$INSTALL -m 755 $f $TOOLCHAIN_SYSROOT/usr/bin/ || error "install $f"
    done

    mkdir -p $TOOLCHAIN_SYSROOT/usr/share/qemu || error
    cp -R pc-bios/*.bin $TOOLCHAIN_SYSROOT/usr/share/qemu/ || error
    cp -R pc-bios/*.x   $TOOLCHAIN_SYSROOT/usr/share/qemu/ || error

    popd
    touch "$STATE_DIR/mingw32_qemu.installed"
}

build_mingw32_qemu
