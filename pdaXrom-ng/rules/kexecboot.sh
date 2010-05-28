#
# packet template
#
# Copyright (C) 2009 by Adrian Crutchfield <insearchof@inventgen-solutions.com
#
# See CREDITS for details about who has contributed to this project.
#
# For further information about the pdaXrom project and license conditions
# see the README file.
#

KEXECBOOT_VERSION=HEAD
KEXECBOOT=kexecboot-${KEXECBOOT_VERSION}
KEXECBOOT_MIRROR=git://git.linuxtogo.org/home/groups/kexecboot/kexecboot.git
KEXECBOOT_DIR=$BUILD_DIR/kexecboot-${KEXECBOOT_VERSION}
KEXECBOOT_ENV="$CROSS_ENV_AC"

build_kexecboot() {
    test -e "$STATE_DIR/kexecboot.installed" && return
    banner "Build kexecboot"
    download_git $KEXECBOOT_MIRROR $KEXECBOOT $KEXECBOOT_VERSION
    extract $KEXECBOOT
    apply_patches $KEXECBOOT_DIR $KEXECBOOT
    pushd $TOP_DIR
    cd $KEXECBOOT_DIR
    (
	./autogen.sh
    eval \
	$CROSS_CONF_ENV \
	$KEXECBOOT_ENV \
	./configure --build=$BUILD_ARCH --host=$TARGET_ARCH \
	    --prefix=/usr \
	    --sysconfdir=/etc \
	    || error
    ) || error "configure"

    make $MAKEARGS || error

    install_sysroot_files || error

    install_fakeroot_init

    install_fakeroot_finish || error

    popd
    touch "$STATE_DIR/kexecboot.installed"
}

build_kexecboot
