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

XUL_VERSION=1.9.1
FIREFOX_VERSION=3.5.7
FIREFOX=firefox-${FIREFOX_VERSION}.source.tar.bz2
FIREFOX_MIRROR=http://releases.mozilla.org/pub/mozilla.org/firefox/releases/${FIREFOX_VERSION}/source
FIREFOX_DIR=$BUILD_DIR/mozilla-${XUL_VERSION}

case $TARGET_ARCH in
arm*)
    FIREFOX_ENV="$CROSS_ENV_AC MOZ_CO_PROJECT=browser CROSS_COMPILE=1 ac_cv_va_copy=C99 ac_cv_va_copy=yes ac_cv_va_val_copy=yes"
    ;;
*)
    FIREFOX_ENV="$CROSS_ENV_AC MOZ_CO_PROJECT=browser CROSS_COMPILE=1 ac_cv_va_copy=C99 ac_cv_va_copy=yes ac_cv_va_val_copy=no"
    ;;
esac

build_firefox() {
    test -e "$STATE_DIR/firefox-${FIREFOX_VERSION}.installed" && return
    banner "Build firefox ${FIREFOX_VERSION}"
    download $FIREFOX_MIRROR $FIREFOX
    extract $FIREFOX
    apply_patches $FIREFOX_DIR $FIREFOX
    pushd $TOP_DIR
    cd $FIREFOX_DIR

    # fix sqlite path
    sed -i -e "s|-LSQLITE_LIB|-L${TARGET_LIB}|" security/nss/lib/softoken/config.mk
    #

    local HOST_LIBIDL_CFLAGS="`unset PKG_CONFIG_PATH; PATH=$(dirname $HOST_PKG_CONFIG):$PATH; host-libIDL-config-2 --cflags`"
    local HOST_LIBIDL_LIBS="`unset PKG_CONFIG_PATH; PATH=$(dirname $HOST_PKG_CONFIG):$PATH; host-libIDL-config-2 --libs`"

    local FF_OPT_ARGS=
    local FF_OPT_CFLAGS=
    case $TARGET_ARCH in
    powerpc64*|ppc64*)
	FF_OPT_ARGS="--disable-necko-wifi"
	FF_OPT_CFLAGS='="-mminimal-toc -O4 -freorder-blocks -fno-reorder-functions"'
	;;
    powerpc*|ppc*)
	FF_OPT_ARGS="--disable-necko-wifi"
	FF_OPT_CFLAGS='="-O4 -freorder-blocks -fno-reorder-functions"'
	;;
    mips*)
	FF_OPT_CFLAGS='="-O4 -freorder-blocks -fno-reorder-functions"'
	#FF_OPT_CFLAGS=
	;;
    esac

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
	    --enable-install-strip \
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
	    --enable-optimize${FF_OPT_CFLAGS} \
	    --enable-pango \
	    --enable-postscript \
    	    --enable-svg \
	    --enable-mathml \
	    --enable-xft \
	    --enable-xinerama \
	    --enable-startup-notification \
	    --enable-extensions=default,-reporter \
	    --enable-single-profile \
	    --enable-system-myspell \
	    --enable-system-sqlite \
	    --with-distribution-id=org.pdaXrom \
	    ${FF_OPT_ARGS}

#	    --enable-system-sqlite

	local T_ARCH=
	local T_CONF=
	case $TARGET_ARCH in
	i386*|i486*|i586*|i686*)
	    T_ARCH="x86"
	    T_CONF="x86"
	    ;;
	arm*l-*|armle-*)
	    T_ARCH="arm"
	    T_CONF="armel"
	    ;;
	arm*b-*|armbe-*)
	    T_ARCH="arm"
	    T_CONF="armeb"
	    ;;
	mipsel-*)
	    T_ARCH="mips"
	    T_CONF="mipsel"
	    ;;
	mips*-*)
	    T_ARCH="mips"
	    T_CONF="mipseb"
	    ;;
	mips64el-*)
	    T_ARCH="mips"
	    T_CONF="mips64el"
	    ;;
	mips64*-*)
	    T_ARCH="mips"
	    T_CONF="mips64eb"
	    ;;
	powerpc-*|ppc-*)
	    T_ARCH="ppc"
	    T_CONF="ppc"
	    ;;
	powerpc64-*|ppc64-*)
	    T_ARCH="ppc"
	    T_CONF="ppc64"
	    ;;
	x86_64*|amd64*)
	    T_ARCH="x86_64"
	    T_CONF="x86_64"
	    ;;
	*)
	    T_ARCH="${TARGET_ARCH/-*/}"
	    ;;
	esac
	sed -i "s|CPU_ARCH =|CPU_ARCH = $T_ARCH|" security/coreconf/Linux.mk
	#cp -f $CONFIG_DIR/firefox3.5/jsautocfg.h-${T_CONF} js/src/jsautocfg.h || error
    ) || error "configure"

    make $MAKEARGS \
	CROSS_COMPILE=1 \
	HOST_CXXFLAGS="$HOST_CPPFLAGS" \
	HOST_CFLAGS="$HOST_CPPFLAGS -DXP_UNIX -DNO_X11 -O $HOST_LIBIDL_CFLAGS" \
	HOST_LDFLAGS="$HOST_LDFLAGS" \
	HOST_LIBIDL_CFLAGS="$HOST_LIBIDL_CFLAGS" \
	HOST_LIBIDL_LIBS="$HOST_LDFLAGS $HOST_LIBIDL_LIBS" \
	HOST_AR="ar" \
	OS_RELEASE="2.6" \
	WARNINGS_AS_ERRORS="" \
    || error

    make $MAKEARGS \
	CROSS_COMPILE=1 \
	HOST_CXXFLAGS="$HOST_CPPFLAGS" \
	HOST_CFLAGS="$HOST_CPPFLAGS -DXP_UNIX -DNO_X11 -O $HOST_LIBIDL_CFLAGS" \
	HOST_LDFLAGS="$HOST_LDFLAGS" \
	HOST_LIBIDL_CFLAGS="$HOST_LIBIDL_CFLAGS" \
	HOST_LIBIDL_LIBS="$HOST_LDFLAGS $HOST_LIBIDL_LIBS" \
	HOST_AR="ar" \
	OS_RELEASE="2.6" \
	DESTDIR="$FIREFOX_DIR/fakeroot" \
	WARNINGS_AS_ERRORS="" \
	install \
    || error

    cp -R fakeroot/usr/lib/firefox-${FIREFOX_VERSION} $ROOTFS_DIR/usr/lib/ || error "copy binaries to rootfs"
    ln -sf firefox-${FIREFOX_VERSION} $ROOTFS_DIR/usr/lib/firefox || error
    ln -sf ../lib/firefox-${FIREFOX_VERSION}/firefox $ROOTFS_DIR/usr/bin/ || error

    $INSTALL -D -m 644 $GENERICFS_DIR/firefox/mozilla-firefox.desktop $ROOTFS_DIR/usr/share/applications/mozilla-firefox.desktop || error
    $INSTALL -D -m 644 $GENERICFS_DIR/firefox/mozilla-firefox.png $ROOTFS_DIR/usr/share/pixmaps/mozilla-firefox.png || error

    $INSTALL -m 644 $GENERICFS_DIR/firefox/browserconfig.properties $ROOTFS_DIR/usr/lib/firefox/browserconfig.properties || error
    $INSTALL -m 644 $GENERICFS_DIR/firefox/firefox-branding.js $ROOTFS_DIR/usr/lib/firefox/defaults/pref/firefox-branding.js || error

    popd
    touch "$STATE_DIR/firefox-${FIREFOX_VERSION}.installed"
}

build_firefox
