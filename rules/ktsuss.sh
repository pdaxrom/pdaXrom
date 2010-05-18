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

KTSUSS_VERSION=1.4
KTSUSS=ktsuss-${KTSUSS_VERSION}.tar.gz
KTSUSS_MIRROR=http://download.berlios.de/ktsuss
KTSUSS_DIR=$BUILD_DIR/ktsuss-${KTSUSS_VERSION}
KTSUSS_ENV="$CROSS_ENV_AC"

build_ktsuss() {
    test -e "$STATE_DIR/ktsuss.installed" && return
    banner "Build ktsuss"
    download $KTSUSS_MIRROR $KTSUSS
    extract $KTSUSS
    apply_patches $KTSUSS_DIR $KTSUSS
    pushd $TOP_DIR
    cd $KTSUSS_DIR
    (
    eval \
	$CROSS_CONF_ENV \
	$KTSUSS_ENV \
	./configure --build=$BUILD_ARCH --host=$TARGET_ARCH \
	    --prefix=/usr \
	    --sysconfdir=/etc \
	    --libexecdir=/usr/lib/ktsuss \
	    || error
    ) || error "configure"

    make $MAKEARGS || error

    #install_sysroot_files || error

    install_fakeroot_init
    install_fakeroot_finish || error
    chmod u+s $ROOTFS_DIR/usr/bin/ktsuss

    popd
    touch "$STATE_DIR/ktsuss.installed"
}

build_ktsuss
