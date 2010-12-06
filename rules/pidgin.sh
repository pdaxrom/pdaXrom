#
# packet template
#
# Copyright (C) 2008 by Alexander Chukov <sash@pdaXrom.org>
#          
# See CREDITS for details about who has contributed to this project.
#
# For further information about the pdaXrom project and license conditions
# see the README file.
#

PIDGIN_VERSION=2.7.7
PIDGIN=pidgin-${PIDGIN_VERSION}.tar.bz2
PIDGIN_MIRROR=http://downloads.sourceforge.net/pidgin
PIDGIN_DIR=$BUILD_DIR/pidgin-${PIDGIN_VERSION}
PIDGIN_ENV="$CROSS_ENV_AC"

build_pidgin() {
    test -e "$STATE_DIR/pidgin-${PIDGIN_VERSION}.installed" && return
    banner "Build pidgin"
    download $PIDGIN_MIRROR $PIDGIN
    extract $PIDGIN
    apply_patches $PIDGIN_DIR $PIDGIN
    pushd $TOP_DIR
    cd $PIDGIN_DIR
    (
    eval \
	$CROSS_CONF_ENV \
	$PIDGIN_ENV \
	./configure --build=$BUILD_ARCH --host=$TARGET_ARCH \
	    --prefix=/usr \
	    --sysconfdir=/etc \
	    --x-includes=$TARGET_INC \
	    --x-libraries=$TARGET_LIB \
	    --disable-gtkspell \
	    --disable-dbus \
	    --disable-tcl \
	    --disable-tk \
	    --disable-doxygen \
	    --disable-meanwhile \
	    --disable-schemas-install \
	    --disable-idn \
	    --disable-avahi \
	    --disable-perl \
	    --disable-python \
	    --enable-gnutls=yes \
	    --with-gnutls-includes=$TARGET_INC \
	    --with-gnutls-libs=$TARGET_LIB \
	    --enable-nss=no \
	    --disable-consoleui \
	    --disable-schemas-install
    ) || error "configure"
    
    make $MAKEARGS || error "make"

    install_fakeroot_init
#    mv fakeroot/usr/share/icons/hicolor fakeroot/usr/share/icons/gnome || error
    install_fakeroot_finish || error

    popd
    touch "$STATE_DIR/pidgin-${PIDGIN_VERSION}.installed"
}

build_pidgin
