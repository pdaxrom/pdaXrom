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

MPG321_VERSION=0.2.11
MPG321=mpg321-${MPG321_VERSION}.tar.gz
MPG321_MIRROR=http://downloads.sourceforge.net/project/mpg321/mpg321/${MPG321_VERSION}
MPG321_DIR=$BUILD_DIR/mpg321
MPG321_ENV="$CROSS_ENV_AC"

build_mpg321() {
    test -e "$STATE_DIR/mpg321.installed" && return
    banner "Build mpg321"
    download $MPG321_MIRROR $MPG321
    extract $MPG321
    apply_patches $MPG321_DIR $MPG321
    pushd $TOP_DIR
    cd $MPG321_DIR
    (
    eval \
	$CROSS_CONF_ENV \
	$MPG321_ENV \
	./configure --build=$BUILD_ARCH --host=$TARGET_ARCH \
	    --prefix=/usr \
	    --sysconfdir=/etc \
	    --with-ao=$TARGET_BIN_DIR \
	    || error
    ) || error "configure"

    make $MAKEARGS || error

    #install_sysroot_files || error

    install_fakeroot_init
    install_fakeroot_finish || error

    popd
    touch "$STATE_DIR/mpg321.installed"
}

build_mpg321
