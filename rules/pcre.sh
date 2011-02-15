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

PCRE_VERSION=8.02
PCRE=pcre-${PCRE_VERSION}.tar.bz2
PCRE_MIRROR=http://downloads.sourceforge.net/project/pcre/pcre/8.02
PCRE_DIR=$BUILD_DIR/pcre-${PCRE_VERSION}
PCRE_ENV="$CROSS_ENV_AC"

build_pcre() {
    test -e "$STATE_DIR/pcre.installed" && return
    banner "Build pcre"
    download $PCRE_MIRROR $PCRE
    extract $PCRE
    apply_patches $PCRE_DIR $PCRE
    pushd $TOP_DIR
    cd $PCRE_DIR
    (
    eval \
	$CROSS_CONF_ENV \
	$PCRE_ENV \
	./configure --build=$BUILD_ARCH --host=$TARGET_ARCH \
	    --prefix=/usr \
	    --sysconfdir=/etc \
	    --enable-utf8 \
	    --enable-unicode-properties \
	    --enable-rebuild-chartables \
	    --enable-pcregrep-libz \
	    --enable-pcregrep-libbz2 \
	    || error
    ) || error "configure"

    make $MAKEARGS || error

    install_sysroot_files || error

    ln -sf $TARGET_BIN_DIR/bin/pcre-config $HOST_BIN_DIR/bin/

    install_fakeroot_init

    rm fakeroot/usr/bin/pcre-config
    rm fakeroot/usr/bin/pcretest

    install_fakeroot_finish || error

    popd
    touch "$STATE_DIR/pcre.installed"
}

build_pcre
