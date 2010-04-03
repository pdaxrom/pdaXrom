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

GLIBMM_VERSION=2.22.1
GLIBMM=glibmm-${GLIBMM_VERSION}.tar.bz2
GLIBMM_MIRROR=http://ftp.gnome.org/pub/GNOME/sources/glibmm/2.22
GLIBMM_DIR=$BUILD_DIR/glibmm-${GLIBMM_VERSION}
GLIBMM_ENV="$CROSS_ENV_AC"

build_glibmm() {
    test -e "$STATE_DIR/glibmm.installed" && return
    banner "Build glibmm"
    download $GLIBMM_MIRROR $GLIBMM
    extract $GLIBMM
    apply_patches $GLIBMM_DIR $GLIBMM
    pushd $TOP_DIR
    cd $GLIBMM_DIR
    (
    eval \
	$CROSS_CONF_ENV \
	$GLIBMM_ENV \
	./configure --build=$BUILD_ARCH --host=$TARGET_ARCH \
	    --prefix=/usr \
	    --sysconfdir=/etc \
	    || error
    ) || error "configure"

    make $MAKEARGS || error

    install_sysroot_files || error

    install_fakeroot_init
    rm -rf fakeroot/usr/share/devhelp fakeroot/usr/share/glibmm-2.4
    rm -rf fakeroot/usr/lib/giomm-2.4 fakeroot/usr/lib/glibmm-2.4
    install_fakeroot_finish || error

    popd
    touch "$STATE_DIR/glibmm.installed"
}

build_glibmm
