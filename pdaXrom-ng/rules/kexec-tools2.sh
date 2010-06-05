#
# packet template
#
# Copyright (C) 2009 by Adrian Crutchfield <insearchof@inventgen-solutions.com>
#
# See CREDITS for details about who has contributed to this project.
#
# For further information about the pdaXrom project and license conditions
# see the README file.
#

KEXEC_TOOLS2_VERSION=2.0.1
KEXEC_TOOLS2=kexec-tools-${KEXEC_TOOLS2_VERSION}.tar.bz2
KEXEC_TOOLS2_MIRROR=http://www.kernel.org/pub/linux/kernel/people/horms/kexec-tools/
KEXEC_TOOLS2_DIR=$BUILD_DIR/kexec-tools-${KEXEC_TOOLS2_VERSION}
KEXEC_TOOLS2_ENV="$CROSS_ENV_AC"

build_kexec_tools2() {
    test -e "$STATE_DIR/kexec_tools2.installed" && return
    banner "Build kexec-tools2"
    download $KEXEC_TOOLS2_MIRROR $KEXEC_TOOLS2
    extract $KEXEC_TOOLS2
    apply_patches $KEXEC_TOOLS2_DIR $KEXEC_TOOLS2
    pushd $TOP_DIR
    cd $KEXEC_TOOLS2_DIR
    (
    eval \
	$CROSS_CONF_ENV \
	$KEXEC_TOOLS2_ENV \
	LDFLAGS=-static \
	./configure --build=$BUILD_ARCH --host=$TARGET_ARCH \
	    --prefix=/usr \
	    --sysconfdir=/etc \
	    || error
    ) || error "configure"

    make $MAKEARGS || error

    #install_sysroot_files || error

    install_fakeroot_init

    install_fakeroot_finish || error

    popd
    touch "$STATE_DIR/kexec_tools2.installed"
}

build_kexec_tools2
