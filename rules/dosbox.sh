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

DOSBOX_VERSION=0.74
DOSBOX=dosbox-${DOSBOX_VERSION}.tar.gz
DOSBOX_MIRROR=http://downloads.sourceforge.net/project/dosbox/dosbox/0.74
DOSBOX_DIR=$BUILD_DIR/dosbox-${DOSBOX_VERSION}
DOSBOX_ENV="$CROSS_ENV_AC"

build_dosbox() {
    test -e "$STATE_DIR/dosbox.installed" && return
    banner "Build dosbox"
    download $DOSBOX_MIRROR $DOSBOX
    extract $DOSBOX
    apply_patches $DOSBOX_DIR $DOSBOX
    pushd $TOP_DIR
    cd $DOSBOX_DIR
    (
    eval \
	$CROSS_CONF_ENV \
	$DOSBOX_ENV \
	./configure --build=$BUILD_ARCH --host=$TARGET_ARCH \
	    --prefix=/usr \
	    --sysconfdir=/etc \
	    || error
    ) || error "configure"

#error "asd"

    make $MAKEARGS || error

    #install_sysroot_files || error

    install_fakeroot_init
    install_fakeroot_finish || error

    popd
    touch "$STATE_DIR/dosbox.installed"
}

build_dosbox
