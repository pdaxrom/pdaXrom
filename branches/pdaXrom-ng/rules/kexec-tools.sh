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

get_kexec_kernel_arch() {
    case $TARGET_ARCH in
    i386*|i486*|i586*|i686*)
	echo i386
	;;
    x86_64*|amd64*)
	echo x86_64
	;;
    arm*|xscale*)
	echo arm
	;;
    powerpc*|ppc*)
	grep -q "^CONFIG_PPC64=y" $KERNEL_DIR/.config && echo powerpc64 || echo powerpc
	;;
    *)
	echo $1
	;;
    esac
}

build_kexec_tools() {
    test -e "$STATE_DIR/kexec_tools.installed" && return
    banner "Build kexec-tools"
    download $KEXEC_TOOLS_MIRROR $KEXEC_TOOLS
    extract $KEXEC_TOOLS
    apply_patches $KEXEC_TOOLS_DIR $KEXEC_TOOLS
    pushd $TOP_DIR
    cd $KEXEC_TOOLS_DIR
    (
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
	./configure --build=$BUILD_ARCH --host=`get_kexec_kernel_arch` \
	    --prefix=/sbin \
	    --sysconfdir=/etc \
	    --without-zlib \
	    --includedir=$KERNEL_DIR/include \
	    || error
    ) || error "configure"
    
    make $MAKEARGS BUILD_CFLAGS='' || error

    error "update install"

    popd
    touch "$STATE_DIR/kexec_tools.installed"
}

build_kexec_tools
