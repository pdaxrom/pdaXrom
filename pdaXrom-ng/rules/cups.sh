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

CUPS_VERSION=1.4rc1
#CUPS_VERSION=1.3.11
CUPS=cups-${CUPS_VERSION}-source.tar.bz2
CUPS_MIRROR=http://ftp.easysw.com/pub/cups/${CUPS_VERSION}
CUPS_DIR=$BUILD_DIR/cups-${CUPS_VERSION}
CUPS_ENV="$CROSS_ENV_AC"

build_cups() {
    test -e "$STATE_DIR/cups.installed" && return
    banner "Build cups"
    download $CUPS_MIRROR $CUPS
    extract $CUPS
    apply_patches $CUPS_DIR $CUPS
    pushd $TOP_DIR
    cd $CUPS_DIR
    (
    eval \
	$CROSS_CONF_ENV \
	$CUPS_ENV \
	./configure --build=$BUILD_ARCH --host=$TARGET_ARCH \
	    --prefix=/usr \
	    --sysconfdir=/etc \
	    --localstatedir=/var \
	    --disable-gssapi \
	    --disable-ldap \
	    || error
    ) || error "configure"
    
    make $MAKEARGS GENSTRINGS=true || error

    rm -rf fakeroot

    make $MAKEARGS GENSTRINGS=true BUILDROOT=${CUPS_DIR}/fakeroot install || error

    cp -a fakeroot/usr/include/cups $TARGET_INC/ || error
    cp -a fakeroot/usr/lib/*.* $TARGET_LIB/ || error

    cp -a fakeroot/usr/bin/cups-config $HOST_BIN_DIR/bin/ || error

    sed -i -e  "/^exec_prefix=/s:\(exec_prefix=\)\(/usr\):\1${TARGET_BIN_DIR}\2:g" 	\
	    -e "/^prefix=/s:\(prefix=\)\(/usr\):\1${TARGET_BIN_DIR}\2:g"		\
	    -e "/^libdir=/s:\(libdir=\)\(/lib\|/usr/lib\):\1${TARGET_BIN_DIR}\2:g"	\
	    $HOST_BIN_DIR/bin/cups-config || true

    rm -rf fakeroot/usr/include fakeroot/usr/share/doc fakeroot/usr/share/locale

    rm -rf fakeroot/etc/rc[0-9].d fakeroot/etc/init.d

    find fakeroot/usr/ ! -type d -a ! -type l | xargs $STRIP

    mv -f fakeroot/usr/share/icons/hicolor fakeroot/usr/share/icons/gnome || error

    rm -f $ROOTFS_DIR/usr/bin/lpr $ROOTFS_DIR/usr/bin/lpq

    cp -a fakeroot/etc $ROOTFS_DIR/ || error
    cp -a fakeroot/usr $ROOTFS_DIR/ || error
    cp -a fakeroot/var $ROOTFS_DIR/ || error

    $INSTALL -D -m 755 $GENERICFS_DIR/etc/init.d/cups $ROOTFS_DIR/etc/init.d/cups || error
    install_rc_start dbus 85
    install_rc_stop  dbus 15

    popd
    touch "$STATE_DIR/cups.installed"
}

build_cups
