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

A52DEC_VERSION=0.7.4
A52DEC=a52dec-${A52DEC_VERSION}.tar.gz
A52DEC_MIRROR=http://liba52.sourceforge.net/files
A52DEC_DIR=$BUILD_DIR/a52dec-${A52DEC_VERSION}
A52DEC_ENV="$CROSS_ENV_AC"

build_a52dec() {
    test -e "$STATE_DIR/a52dec.installed" && return
    banner "Build a52dec"
    download $A52DEC_MIRROR $A52DEC
    extract $A52DEC
    apply_patches $A52DEC_DIR $A52DEC
    pushd $TOP_DIR
    cd $A52DEC_DIR
    (
    eval \
	$CROSS_CONF_ENV \
	$A52DEC_ENV \
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
    touch "$STATE_DIR/a52dec.installed"
}

build_a52dec
