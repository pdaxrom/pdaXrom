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

PIDGIN=pidgin-2.5.3.tar.bz2
PIDGIN_MIRROR=http://downloads.sourceforge.net/pidgin
PIDGIN_DIR=$BUILD_DIR/pidgin-2.5.3
PIDGIN_ENV="$CROSS_ENV_AC"

build_pidgin() {
    test -e "$STATE_DIR/pidgin.installed" && return
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
	    --disable-gstreamer \
	    --disable-gtkspell \
	    --disable-dbus \
	    --disable-tcl \
	    --disable-tk \
	    --disable-doxygen \
	    --disable-meanwhile \
	    --disable-schemas-install \
	    --disable-avahi \
	    --disable-perl \
	    --disable-python \
	    --enable-gnutls=yes \
	    --with-gnutls-includes=$TARGET_INC \
	    --with-gnutls-libs=$TARGET_LIB \
	    --enable-nss=no \
	    --disable-consoleui \
	    --disable-schemas-install \
	    --with-static-prpls=gg,irc,jabber,msn,oscar,yahoo,simple
    ) || error "configure"
    
    make $MAKEARGS || error "make"

    make DESTDIR=$PIDGIN_DIR/fakeroot install || error "install"
    
    rm -rf fakeroot/usr/include fakeroot/usr/lib/pkgconfig fakeroot/usr/lib/*.la || error "del 1"
    rm -rf fakeroot/usr/share/aclocal fakeroot/usr/share/locale fakeroot/usr/share/man || error "del 2"
    rm -f fakeroot/usr/lib/pidgin/*.la
    rm -f fakeroot/usr/lib/purple-2/*.la
    
    $STRIP fakeroot/usr/bin/pidgin || error
    $STRIP fakeroot/usr/lib/libpurple.so.0.5.3 || error
    $STRIP fakeroot/usr/lib/pidgin/*.so || error
    $STRIP fakeroot/usr/lib/purple-2/*.so || error

    cp -R fakeroot/usr $ROOTFS_DIR/ || error

    popd
    touch "$STATE_DIR/pidgin.installed"
}

build_pidgin
