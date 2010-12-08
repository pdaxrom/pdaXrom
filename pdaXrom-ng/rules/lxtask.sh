#
# packet template
#
# Copyright (C) 2010 by Alexander Chukov <sash@pdaXrom.org>
#
# See CREDITS for details about who has contributed to this project.
#
# For further information about the pdaXrom project and license conditions
# see the README file.
#

LXTASK_VERSION=0.1.3
LXTASK=lxtask-${LXTASK_VERSION}.tar.gz
LXTASK_MIRROR=http://downloads.sourceforge.net/project/lxde/LXTask%20%28task%20manager%29/LXTask%200.1.3
LXTASK_DIR=$BUILD_DIR/lxtask-${LXTASK_VERSION}
LXTASK_ENV="$CROSS_ENV_AC"

build_lxtask() {
    test -e "$STATE_DIR/lxtask.installed" && return
    banner "Build lxtask"
    download $LXTASK_MIRROR $LXTASK
    extract $LXTASK
    apply_patches $LXTASK_DIR $LXTASK
    pushd $TOP_DIR
    cd $LXTASK_DIR
    (
    eval \
	$CROSS_CONF_ENV \
	$LXTASK_ENV \
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
    touch "$STATE_DIR/lxtask.installed"
}

build_lxtask
