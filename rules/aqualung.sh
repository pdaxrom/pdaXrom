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

AQUALUNG_VERSION=0.9beta10
AQUALUNG=aqualung-${AQUALUNG_VERSION}.tar.gz
AQUALUNG_MIRROR=http://downloads.sourceforge.net/aqualung
AQUALUNG_DIR=$BUILD_DIR/aqualung-${AQUALUNG_VERSION}
AQUALUNG_ENV="$CROSS_ENV_AC"

build_aqualung() {
    test -e "$STATE_DIR/aqualung.installed" && return
    banner "Build aqualung"
    download $AQUALUNG_MIRROR $AQUALUNG
    extract $AQUALUNG
    apply_patches $AQUALUNG_DIR $AQUALUNG
    pushd $TOP_DIR
    cd $AQUALUNG_DIR
    (
    eval \
	$CROSS_CONF_ENV \
	$AQUALUNG_ENV \
	./configure --build=$BUILD_ARCH --host=$TARGET_ARCH \
	    --prefix=/usr \
	    --sysconfdir=/etc \
	    --with-oss=no \
	    --with-jack=no \
	    || error
    ) || error "configure"

    make $MAKEARGS || error

    #install_sysroot_files || error

    install_fakeroot_init
    install_fakeroot_finish || error

    install -D -m 644 $GENERICFS_DIR/applications/aqualung.desktop $ROOTFS_DIR/usr/share/applications/aqualung.desktop || error "install desktop file"

    popd
    touch "$STATE_DIR/aqualung.installed"
}

build_aqualung
