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

GCONF_VERSION=2.28.0
GCONF=GConf-${GCONF_VERSION}.tar.bz2
GCONF_MIRROR=ftp://ftp.gnome.org/pub/GNOME/sources/GConf/2.28
GCONF_DIR=$BUILD_DIR/GConf-${GCONF_VERSION}
GCONF_ENV="$CROSS_ENV_AC"

build_GConf() {
    test -e "$STATE_DIR/GConf.installed" && return
    banner "Build GConf"
    download $GCONF_MIRROR $GCONF
    extract $GCONF
    apply_patches $GCONF_DIR $GCONF
    pushd $TOP_DIR
    cd $GCONF_DIR
    (
    eval \
	$CROSS_CONF_ENV \
	$GCONF_ENV \
	./configure --build=$BUILD_ARCH --host=$TARGET_ARCH \
	    --prefix=/usr \
	    --sysconfdir=/etc \
	    --libexecdir=/usr/lib/GConf \
	    --with-openldap=no \
	    --enable-defaults-service=no \
	    --enable-gtk=no \
	    --enable-gtk-doc=no \
	    || error
    ) || error "configure"

    make $MAKEARGS ORBIT_IDL=${HOST_BIN_DIR}/bin/orbit-idl-2 || error

    install_sysroot_files || error

    install_fakeroot_init
    install_fakeroot_finish || error

    popd
    touch "$STATE_DIR/GConf.installed"
}

build_GConf
