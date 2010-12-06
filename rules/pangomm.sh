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

PANGOMM_VERSION=2.26.0
PANGOMM=pangomm-${PANGOMM_VERSION}.tar.bz2
PANGOMM_MIRROR=http://ftp.gnome.org/pub/GNOME/sources/pangomm/2.26
PANGOMM_DIR=$BUILD_DIR/pangomm-${PANGOMM_VERSION}
PANGOMM_ENV="$CROSS_ENV_AC"

build_pangomm() {
    test -e "$STATE_DIR/pangomm.installed" && return
    banner "Build pangomm"
    download $PANGOMM_MIRROR $PANGOMM
    extract $PANGOMM
    apply_patches $PANGOMM_DIR $PANGOMM
    pushd $TOP_DIR
    cd $PANGOMM_DIR
    (
    eval \
	$CROSS_CONF_ENV \
	$PANGOMM_ENV \
	./configure --build=$BUILD_ARCH --host=$TARGET_ARCH \
	    --prefix=/usr \
	    --sysconfdir=/etc \
	    || error
    ) || error "configure"

    make $MAKEARGS || error

    install_sysroot_files || error

    install_fakeroot_init
    rm -rf fakeroot/usr/lib/pangomm-1.4 fakeroot/usr/share/devhelp
    install_fakeroot_finish || error

    popd
    touch "$STATE_DIR/pangomm.installed"
}

build_pangomm
