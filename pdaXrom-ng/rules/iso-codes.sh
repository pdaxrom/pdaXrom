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

ISO_CODES_VERSION=3.21
ISO_CODES=iso-codes-${ISO_CODES_VERSION}.tar.bz2
ISO_CODES_MIRROR=http://ftp.uni-erlangen.de/pub/mirrors/gentoo/distfiles
ISO_CODES_DIR=$BUILD_DIR/iso-codes-${ISO_CODES_VERSION}
ISO_CODES_ENV="$CROSS_ENV_AC"

build_iso_codes() {
    test -e "$STATE_DIR/iso_codes.installed" && return
    banner "Build iso-codes"
    download $ISO_CODES_MIRROR $ISO_CODES
    extract $ISO_CODES
    apply_patches $ISO_CODES_DIR $ISO_CODES
    pushd $TOP_DIR
    cd $ISO_CODES_DIR
    (
    eval \
	$CROSS_CONF_ENV \
	$ISO_CODES_ENV \
	./configure --build=$BUILD_ARCH --host=$TARGET_ARCH \
	    --prefix=/usr \
	    --sysconfdir=/etc \
	    || error
    ) || error "configure"

    make $MAKEARGS || error

    install_sysroot_files || error
    ln -sf ${TARGET_BIN_DIR}/usr/share/pkgconfig/iso-codes.pc ${TARGET_LIB}/pkgconfig/iso-codes.pc

    install_fakeroot_init
    rm -rf fakeroot/usr/share/pkgconfig
    install_fakeroot_finish || error

    popd
    touch "$STATE_DIR/iso_codes.installed"
}

build_iso_codes
