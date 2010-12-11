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

HT_VERSION=2.0.18
HT=ht-${HT_VERSION}.tar.bz2
HT_MIRROR=http://downloads.sourceforge.net/project/hte/ht-source
HT_DIR=$BUILD_DIR/ht-${HT_VERSION}
HT_ENV="$CROSS_ENV_AC"

build_ht() {
    test -e "$STATE_DIR/ht.installed" && return
    banner "Build ht"
    download $HT_MIRROR $HT
    extract $HT
    apply_patches $HT_DIR $HT
    pushd $TOP_DIR
    cd $HT_DIR
    (
    eval \
	$CROSS_CONF_ENV \
	$HT_ENV \
	./configure --build=$BUILD_ARCH --host=$TARGET_ARCH \
	    --prefix=/usr \
	    --sysconfdir=/etc \
	    || error
    ) || error "configure"

    make -C tools CC=gcc $MAKEARGS || error

    make $MAKEARGS || error

    #install_sysroot_files || error

    install_fakeroot_init
    install_fakeroot_finish || error

    popd
    touch "$STATE_DIR/ht.installed"
}

build_ht
