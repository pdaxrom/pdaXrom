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

TINT2_VERSION=0.7.1
TINT2=tint2-${TINT2_VERSION}.tar.gz
TINT2_MIRROR=http://tint2.googlecode.com/files
TINT2_DIR=$BUILD_DIR/tint2-${TINT2_VERSION}
TINT2_ENV="$CROSS_ENV_AC"

build_tint2() {
    test -e "$STATE_DIR/tint2.installed" && return
    banner "Build tint2"
    download $TINT2_MIRROR $TINT2
    extract $TINT2
    apply_patches $TINT2_DIR $TINT2
    pushd $TOP_DIR
    cd $TINT2_DIR
    (
    eval \
	$CROSS_CONF_ENV \
	$TINT2_ENV \
	./configure --build=$BUILD_ARCH --host=$TARGET_ARCH \
	    --prefix=/usr \
	    --sysconfdir=/etc \
	    || error
    ) || error "configure"

    make $MAKEARGS || error

    #install_sysroot_files || error

    install_fakeroot_init
    $INSTALL -D -m 644 ${GENERICFS_DIR}/tint2/tint2rc fakeroot/etc/xdg/tint2/tint2rc
    install_fakeroot_finish || error

    popd
    touch "$STATE_DIR/tint2.installed"
}

build_tint2
