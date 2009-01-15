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
FIREFOX_ENV="$CROSS_ENV_AC MOZ_CO_PROJECT=browser CROSS_COMPILE=1 ac_cv_va_copy=C99 ac_cv_va_copy=yes ac_cv_va_val_copy=no"

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
	    --enable-system-cairo \
	    --disable-debug \
	    --with-user-appdir=.mozilla \
	    --with-system-jpeg=$TARGET_BIN_DIR \
	    --with-system-zlib=$TARGET_BIN_DIR \
	    --disable-crashreporter \
	    --disable-composer \
	    --disable-elf-dynstr-gc \
	    --disable-gtktest \
	    --disable-install-strip \
	    --disable-installer \
	    --disable-ldap \
	    --disable-mailnews \
	    --disable-profilesharing \
	    --disable-tests \
	    --disable-mochitest \
	    --disable-updater \
	    --disable-xprint \
	    --enable-application=browser \
	    --enable-canvas \
	    --enable-default-toolkit=cairo-gtk2 \
	    --disable-gnomevfs \
	    --disable-dbus \
	    --enable-optimize \
	    --enable-pango \
	    --enable-postscript \
    	    --enable-svg \
	    --enable-mathml \
	    --enable-xft \
	    --enable-xinerama \
	    --enable-extensions=default,-reporter \
	    --enable-single-profile \
	    --enable-system-myspell \
	    --with-distribution-id=org.pdaXrom

#	    --enable-system-sqlite

	local T_ARCH=
	case $TARGET_ARCH in
	i386*|i486*|i586*|i686*)
	    T_ARCH="x86"
	    ;;
	arm*|xscale*)
	    T_ARCH="arm"
	    ;;
	powerpc*|ppc*)
	    T_ARCH="ppc"
	    ;;
	x86_64*|amd64*)
	    T_ARCH="x86_64"
	    ;;
	*)
	    T_ARCH="${TARGET_ARCH/-*/}"
	    ;;
	esac
	sed -i "s|CPU_ARCH =|CPU_ARCH = $T_ARCH|" security/coreconf/Linux.mk
	cp -f $CONFIG_DIR/firefox3/jsautocfg.h-${T_ARCH} js/src/jsautocfg.h || error
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

    $INSTALL -m 644 $GENERICFS_DIR/firefox/browserconfig.properties $ROOTFS_DIR/usr/lib/firefox/browserconfig.properties || error
    $INSTALL -m 644 $GENERICFS_DIR/firefox/firefox-branding.js $ROOTFS_DIR/usr/lib/firefox/defaults/pref/firefox-branding.js || error

    popd
    touch "$STATE_DIR/firefox.installed"
}

build_firefox
