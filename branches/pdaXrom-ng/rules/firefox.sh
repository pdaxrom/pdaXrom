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

FIREFOX=firefox-3.0.5-source.tar.bz2
FIREFOX_MIRROR=http://releases.mozilla.org/pub/mozilla.org/firefox/releases/3.0.5/source
FIREFOX_DIR=$BUILD_DIR/mozilla
FIREFOX_ENV="$CROSS_ENV_AC MOZ_CO_PROJECT=browser CROSS_COMPILE=1 ac_cv_va_copy=C99 ac_cv___va_copy=yes"

build_firefox() {
    test -e "$STATE_DIR/firefox.installed" && return
    banner "Build firefox"
    download $FIREFOX_MIRROR $FIREFOX
    extract $FIREFOX
    apply_patches $FIREFOX_DIR $FIREFOX
    pushd $TOP_DIR
    cd $FIREFOX_DIR
    (
    eval \
	$CROSS_CONF_ENV \
	$FIREFOX_ENV \
	./configure --build=$BUILD_ARCH --target=$TARGET_ARCH \
	    --prefix=/usr \
	    --sysconfdir=/etc \
	    --x-includes=$TARGET_INC \
	    --x-libraries=$TARGET_LIB \
	    --enable-application=browser \
	    --enable-default-toolkit=cairo-gtk2 \
	    --enable-xft \
	    --disable-freetype2 \
	    --enable-system-cairo \
	    --disable-gtktest \
	    --disable-tests \
	    --disable-static \
	    --disable-gnomevfs \
	    --disable-dbus \
	    --disable-debug \
	    --enable-strip \
	    --disable-crashreporter
	sed -i "s|CPU_ARCH =|CPU_ARCH = $TARGET_ARCH|" security/coreconf/Linux.mk
    ) || error "configure"

    make $MAKEARGS \
	CROSS_COMPILE=1 \
	HOST_CXXFLAGS="$HOST_CPPFLAGS" \
	HOST_CFLAGS="$HOST_CPPFLAGS -DXP_UNIX -DNO_X11 -O `host-libIDL-config-2 --cflags`" \
	HOST_LDFLAGS="$HOST_LDFLAGS" \
	HOST_LIBIDL_CFLAGS="`host-libIDL-config-2 --cflags`" \
	HOST_LIBIDL_LIBS="$HOST_LDFLAGS `host-libIDL-config-2 --libs`" \
	HOST_AR="ar" \
	OS_RELEASE="2.6" \
    || error

    make $MAKEARGS \
	CROSS_COMPILE=1 \
	HOST_CXXFLAGS="$HOST_CPPFLAGS" \
	HOST_CFLAGS="$HOST_CPPFLAGS -DXP_UNIX -DNO_X11 -O `host-libIDL-config-2 --cflags`" \
	HOST_LDFLAGS="$HOST_LDFLAGS" \
	HOST_LIBIDL_CFLAGS="`host-libIDL-config-2 --cflags`" \
	HOST_LIBIDL_LIBS="$HOST_LDFLAGS `host-libIDL-config-2 --libs`" \
	HOST_AR="ar" \
	OS_RELEASE="2.6" \
	DESTDIR="$FIREFOX_DIR/fakeroot" \
	install \
    || error

    cp -R fakeroot/usr/lib/firefox-3.0.5 $ROOTFS_DIR/usr/lib/ || error "copy binaries to rootfs"
    ln -sf firefox-3.0.5 $ROOTFS_DIR/usr/lib/firefox || error
    ln -sf ../lib/firefox-3.0.5/firefox $ROOTFS_DIR/usr/bin/ || error

    $INSTALL -D -m 644 $GENERICFS_DIR/firefox/mozilla-firefox.desktop $ROOTFS_DIR/usr/share/applications/mozilla-firefox.desktop || error
    $INSTALL -D -m 644 $GENERICFS_DIR/firefox/mozilla-firefox.png $ROOTFS_DIR/usr/share/pixmaps/mozilla-firefox.png || error

    popd
    touch "$STATE_DIR/firefox.installed"
}

build_firefox
