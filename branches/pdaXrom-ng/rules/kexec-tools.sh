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

KEXEC_TOOLS=kexec-tools-1.101.tar.gz
KEXEC_TOOLS_MIRROR=http://www.xmission.com/~ebiederm/files/kexec
KEXEC_TOOLS_DIR=$BUILD_DIR/kexec-tools-1.101
KEXEC_TOOLS_ENV="$CROSS_ENV_AC CFLAGS='-Wall -O2 -static -fno-strict-aliasing'"

build_kexec_tools() {
    test -e "$STATE_DIR/kexec_tools.installed" && return
    banner "Build kexec-tools"
    download $KEXEC_TOOLS_MIRROR $KEXEC_TOOLS
    extract $KEXEC_TOOLS
    apply_patches $KEXEC_TOOLS_DIR $KEXEC_TOOLS
    pushd $TOP_DIR
    cd $KEXEC_TOOLS_DIR
    (
    KEXEC_AUTOCONF=
    grep -q "^CONFIG_PPC_PS3=y" $KERNEL_DIR/.config && KEXEC_AUTOCONF="ARCH=ppc64"
    autoconf
    eval \
	$CROSS_CONF_ENV \
	$KEXEC_TOOLS_ENV \
	CC=${CROSS}gcc \
	CPP=${CROSS}cpp \
	AS=${CROSS}as \
	LD=${CROSS}ld \
	AR=${CROSS}ar \
	RANLIB=${CROSS}ranlib \
	OBJCOPY=${CROSS}objcopy \
	STRIP=${CROSS}strip \
	./configure --build=$BUILD_ARCH --host=$TARGET_ARCH \
	    --prefix=/sbin \
	    --sysconfdir=/etc \
	    --without-zlib \
	    --includedir=$KERNEL_DIR/include \
	    $KEXEC_AUTOCONF \
	    || error
    ) || error "configure"
    
    make $MAKEARGS BUILD_CFLAGS='' LDFLAGS='' || error

    $INSTALL -D -m 755 objdir-${TARGET_ARCH}/build/sbin/kexec $ROOTFS_DIR/sbin/kexec || error
    $STRIP $ROOTFS_DIR/sbin/kexec || error

    popd
    touch "$STATE_DIR/kexec_tools.installed"
}

build_kexec_tools
