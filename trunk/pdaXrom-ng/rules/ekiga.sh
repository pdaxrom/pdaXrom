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

EKIGA_VERSION=3.2.6
EKIGA=ekiga-${EKIGA_VERSION}.tar.gz
EKIGA_MIRROR=http://www.ekiga.org/admin/downloads/latest/sources/ekiga_3.2.6
EKIGA_DIR=$BUILD_DIR/ekiga-${EKIGA_VERSION}
EKIGA_ENV="$CROSS_ENV_AC"

build_ekiga() {
    test -e "$STATE_DIR/ekiga.installed" && return
    banner "Build ekiga"
    download $EKIGA_MIRROR $EKIGA
    extract $EKIGA
    apply_patches $EKIGA_DIR $EKIGA
    pushd $TOP_DIR
    cd $EKIGA_DIR
    (
    eval \
	$CROSS_CONF_ENV \
	$EKIGA_ENV \
	./configure --build=$BUILD_ARCH --host=$TARGET_ARCH \
	    --prefix=/usr \
	    --sysconfdir=/etc \
	    --enable-gnome=no \
	    --enable-gconf \
	    --enable-eds=no \
	    --enable-ldap=no \
	    --enable-avahi=no \
	    --enable-gdu=no \
	    --enable-gstreamer \
	    || error
    ) || error "configure"

    make $MAKEARGS || error

    install_fakeroot_init
    install_fakeroot_finish || error

    popd
    touch "$STATE_DIR/ekiga.installed"
}

build_ekiga
